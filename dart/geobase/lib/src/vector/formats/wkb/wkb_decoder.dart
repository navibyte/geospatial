// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'wkb_format.dart';

class _WkbGeometryDecoder implements ContentDecoder {
  final GeometryContent builder;
  //final bool singlePrecision;

  _WkbGeometryDecoder(
    this.builder, //{
    // ignore: unused_element
    // this.singlePrecision = false,
    //}
  );

  @override
  void decodeBytes(Uint8List source, {Map<String, dynamic>? options}) {
    _WkbGeometryBufferDecoder(
      builder,
      ByteReader.view(source),
      //singlePrecision: singlePrecision,
    ).buildAll();
  }

  @override
  void decodeText(String source, {Map<String, dynamic>? options}) =>
      decodeBytes(base64.decode(source), options: options);

  @override
  void decodeData(dynamic source, {Map<String, dynamic>? options}) =>
      const FormatException('Unsupported input data');

  static Coords _decodeCoordTypeFromBytes(Uint8List source) {
    final buffer = ByteReader.view(source);

    // read byte order
    final endian = _readByteOrder(buffer);

    // read geometry type (as specified by the WKBGeometryType enum)
    final typeId = buffer.readUint32(endian);

    // resolve coordinate type from WKB id
    return Coords.fromWkbId(typeId);
  }
}

Endian _readByteOrder(ByteReader buffer) {
  final byteOrder = buffer.readInt8();
  switch (byteOrder) {
    // wkbXDR (= 0 // Big Endian) value of the WKBByteOrder enum
    case 0:
      return Endian.big;
    // wkbNDR (= 1 // Little Endian) value of the WKBByteOrder enum
    case 1:
      return Endian.little;
    default:
      throw const FormatException('Invalid byte order (endian)');
  }
}

class _WkbGeometryBufferDecoder {
  final GeometryContent builder;
  final ByteReader buffer;
  final bool singlePrecision;

  _WkbGeometryBufferDecoder(
    this.builder,
    this.buffer, {
    this.singlePrecision = false,
  });

  void buildAll() {
    // loop as long as some data available, so builds all geometries from buffer
    while (buffer.hasAvailable) {
      _buildGeometry();
    }
  }

  void buildCounted(int count) {
    // build given number ("count") of geometries
    for (var i = 0; i < count; i++) {
      _buildGeometry();
    }
  }

  void _buildGeometry() {
    // read byte order
    final endian = _readByteOrder(buffer);

    // read geometry type (as specified by the WKBGeometryType enum)
    final typeId = buffer.readUint32(endian);

    // resolve coordinate and geometry types from WKB id
    final coordType = Coords.fromWkbId(typeId);
    final geomType = Geom.fromWkbId(typeId);

    // check if data is EWKB and has SRID flag on
    final hasSRID = (typeId & 0x20000000) != 0;

    // read SRID but ignore it if such field exists
    // (NOTE: in future version this data should be exposed to decoder client)
    if (hasSRID) {
      buffer.readUint32(endian);
    }

    // depending on the geometry type, read geometry data and build objects
    switch (geomType) {
      case Geom.point:
        _buildPoint(coordType, endian);
        break;
      case Geom.lineString:
        _buildLineString(coordType, endian);
        break;
      case Geom.polygon:
        _buildPolygon(coordType, endian);
        break;
      case Geom.multiPoint:
        _buildMultiPoint(coordType, endian);
        break;
      case Geom.multiLineString:
        _buildMultiLineString(coordType, endian);
        break;
      case Geom.multiPolygon:
        _buildMultiPolygon(coordType, endian);
        break;
      case Geom.geometryCollection:
        // read number of points
        final numGeometries = buffer.readUint32(endian);

        // build geometry collection
        builder.geometryCollection(
          type: coordType,
          count: numGeometries,
          // use callback content interface to build "numGeometries" to buffer
          (geom) => _WkbGeometryBufferDecoder(
            geom,
            buffer,
            singlePrecision: singlePrecision,
          ).buildCounted(numGeometries),
        );
        break;
    }
  }

  void _buildPoint(Coords coordType, Endian endian) {
    final position = _readPosition(coordType, endian);
    if (position.x.isNaN && position.y.isNaN) {
      // this is a special case, see => https://trac.osgeo.org/geos/ticket/1005
      //                             https://trac.osgeo.org/postgis/ticket/3181
      builder.emptyGeometry(Geom.point);
    } else {
      builder.point(position);
    }
  }

  void _buildLineString(Coords coordType, Endian endian) {
    final chain = _readPositionSeries(coordType, endian);
    if (chain.isEmptyByGeometry) {
      builder.emptyGeometry(Geom.lineString);
    } else {
      builder.lineString(chain);
    }
  }

  void _buildPolygon(Coords coordType, Endian endian) {
    final rings = _readPositionSeriesArray(coordType, endian);
    if (rings.isEmpty) {
      builder.emptyGeometry(Geom.polygon);
    } else {
      builder.polygon(rings);
    }
  }

  void _buildMultiPoint(Coords coordType, Endian endian) {
    final array =
        _readPositionArray(coordType, endian, requireHeaderForItems: true);
    if (array.isEmpty) {
      builder.emptyGeometry(Geom.multiPoint);
    } else {
      builder.multiPoint(array);
    }
  }

  void _buildMultiLineString(Coords coordType, Endian endian) {
    final array = _readPositionSeriesArray(
      coordType,
      endian,
      requireHeaderForItems: true,
    );
    if (array.isEmpty) {
      builder.emptyGeometry(Geom.multiLineString);
    } else {
      builder.multiLineString(array);
    }
  }

  void _buildMultiPolygon(Coords coordType, Endian endian) {
    final array = _readPositionSeriesArrayArray(
      coordType,
      endian,
      requireHeaderForItems: true,
    );
    if (array.isEmpty) {
      builder.emptyGeometry(Geom.multiPolygon);
    } else {
      builder.multiPolygon(array);
    }
  }

  Coords _readCoordTypeAndExpectGeomType(Geom expectGeomType, Endian endian) {
    // read geometry type (as specified by the WKBGeometryType enum)
    final typeId = buffer.readUint32(endian);

    // require geom type to be the expected one
    final geomType = Geom.fromWkbId(typeId);
    if (geomType != expectGeomType) {
      throw const FormatException(
        'Invalid geometry header for item on array',
      );
    }

    // resolve coordinate type from WKB id
    return Coords.fromWkbId(typeId);
  }

  Position _readPosition(
    Coords coordType,
    Endian endian, {
    Coords? outputType,
  }) {
    // all points has at least x and y values
    final x = buffer.readFloat64(endian);
    final y = buffer.readFloat64(endian);

    // read also z and m if input data has them
    final optZ = coordType.is3D ? buffer.readFloat64(endian) : null;
    final optM = coordType.isMeasured ? buffer.readFloat64(endian) : null;

    // coordinate type for returned List<double> list
    final type = outputType ?? coordType;

    // create fixed size list for point coordinates
    final list = singlePrecision
        ? Float32List(type.coordinateDimension)
        : Float64List(type.coordinateDimension);
    list[0] = x;
    list[1] = y;

    // write z and m if output needs them
    if (type.is3D) {
      list[2] = optZ ?? 0.0;
    }
    if (type.isMeasured) {
      list[type.indexForM!] = optM ?? 0.0;
    }

    return Position.view(list, type: type);
  }

  List<Position> _readPositionArray(
    Coords coordType,
    Endian endian, {
    bool requireHeaderForItems = false,
  }) {
    // read number of points
    final numPoints = buffer.readUint32(endian);

    // return a generated list of points
    if (requireHeaderForItems) {
      return List<Position>.generate(
        numPoints,
        (_) {
          // read byte order + type, expect point geom, and return coord type
          final pointEndian = _readByteOrder(buffer);
          final pointCoordType = _readCoordTypeAndExpectGeomType(
            Geom.point,
            pointEndian,
          );
          // read point and add it to a list to be generated
          return _readPosition(
            pointCoordType,
            pointEndian,
            outputType: coordType,
          );
        },
        growable: false,
      );
    } else {
      return List<Position>.generate(
        numPoints,
        (_) {
          // read point and add it to a list to be generated
          return _readPosition(coordType, endian);
        },
        growable: false,
      );
    }
  }

  PositionSeries _readPositionSeries(
    Coords coordType,
    Endian endian, {
    Coords? outputType,
  }) {
    // read number of points
    final numPoints = buffer.readUint32(endian);

    // output: coordinate type for returned List<double> list
    final type = outputType ?? coordType;
    final dim = type.coordinateDimension;
    final numOutputValues = dim * numPoints;

    // create fixed size list for coordinates of all points as flat structure
    final list = singlePrecision
        ? Float32List(numOutputValues)
        : Float64List(numOutputValues);

    for (var start = 0; start < numOutputValues; start += dim) {
      // all points has at least x and y values
      list[start + 0] = buffer.readFloat64(endian);
      list[start + 1] = buffer.readFloat64(endian);

      // read also z and m if input data has them (read even if not outputted)
      final optZ = coordType.is3D ? buffer.readFloat64(endian) : null;
      final optM = coordType.isMeasured ? buffer.readFloat64(endian) : null;

      // write z and m if output needs them
      if (type.is3D) {
        list[start + 2] = optZ ?? 0.0;
      }
      if (type.isMeasured) {
        list[start + type.indexForM!] = optM ?? 0.0;
      }
    }

    return PositionSeries.view(list, type: type);
  }

  List<PositionSeries> _readPositionSeriesArray(
    Coords coordType,
    Endian endian, {
    bool requireHeaderForItems = false,
    Coords? outputType,
  }) {
    // read number of line string (or liner rings)
    final numLineStrings = buffer.readUint32(endian);

    // return a generated list of line strings (or linear rings)
    if (requireHeaderForItems) {
      return List<PositionSeries>.generate(
        numLineStrings,
        (_) {
          // read byte order + type, expect line string, and return coord type
          final lineStringEndian = _readByteOrder(buffer);
          final lineStringCoordType = _readCoordTypeAndExpectGeomType(
            Geom.lineString,
            lineStringEndian,
          );

          // read points of line string and add it to a list to be generated
          return _readPositionSeries(
            lineStringCoordType,
            lineStringEndian,
            outputType: outputType ?? coordType,
          );
        },
        growable: false,
      );
    } else {
      return List<PositionSeries>.generate(
        numLineStrings,
        (_) {
          // read points of line string and add it to a list to be generated
          return _readPositionSeries(
            coordType,
            endian,
            outputType: outputType ?? coordType,
          );
        },
        growable: false,
      );
    }
  }

  List<List<PositionSeries>> _readPositionSeriesArrayArray(
    Coords coordType,
    Endian endian, {
    bool requireHeaderForItems = false,
  }) {
    // read number of polygons
    final numPolygons = buffer.readUint32(endian);

    // return a generated list of polygons
    if (requireHeaderForItems) {
      return List<List<PositionSeries>>.generate(
        numPolygons,
        (_) {
          // read byte order + type, expect polygon, and return coord type
          final polygonEndian = _readByteOrder(buffer);
          final polygonCoordType = _readCoordTypeAndExpectGeomType(
            Geom.polygon,
            polygonEndian,
          );

          // read linear rings of polygon + add it to a list to be generated
          return _readPositionSeriesArray(
            polygonCoordType,
            polygonEndian,
            outputType: coordType,
          );
        },
        growable: false,
      );
    } else {
      return List<List<PositionSeries>>.generate(
        numPolygons,
        (_) {
          // read linear rings of polygon + add it to a list to be generated
          return _readPositionSeriesArray(coordType, endian);
        },
        growable: false,
      );
    }
  }
}
