// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'wkb_format.dart';

class _WkbGeometryDecoder implements ContentDecoder {
  final GeometryContent builder;
  final Endian endian;
  final WkbConf conf;

  _WkbGeometryDecoder(this.builder, {this.endian = Endian.big, WkbConf? conf})
      : conf = conf ?? const WkbConf();

  @override
  void decodeBytes(ByteBuffer source) {
    _WkbGeometryBufferDecoder(
      builder,
      ByteReader.view(source, endian: endian),
      conf,
    ).buildAll();
  }

  @override
  void decodeText(String source) => decodeBytes(base64.decode(source).buffer);
}

class _WkbGeometryBufferDecoder {
  final SimpleGeometryContent builder;
  final ByteReader buffer;
  final WkbConf conf;

  _WkbGeometryBufferDecoder(this.builder, this.buffer, this.conf);

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
    final endian = _readByteOrder();

    // read geometry type (as specified by the WKBGeometryType enum)
    final typeId = buffer.readUint32(endian);

    // resolve coordinate and geometry types from WKB id
    final coordType = Coords.fromWkbId(typeId);
    final geomType = Geom.fromWkbId(typeId);

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
          // use callback content interface to build "numGeometries" to buffer
          (geom) => _WkbGeometryBufferDecoder(geom, buffer, conf)
              .buildCounted(numGeometries),
        );
        break;
    }
  }

  void _buildPoint(Coords coordType, Endian endian) {
    final point = _readPoint(coordType, endian);
    if (conf.buildEmptyGeometries &&
        point[0] == double.nan &&
        point[1] == double.nan) {
      // this is a special case, see => https://trac.osgeo.org/geos/ticket/1005
      //                             https://trac.osgeo.org/postgis/ticket/3181
      builder.emptyGeometry(Geom.point);
    } else {
      builder.point(
        point,
        type: coordType,
      );
    }
  }

  void _buildLineString(Coords coordType, Endian endian) {
    final array = _readPointArray(coordType, endian);
    if (conf.buildEmptyGeometries && array.isEmpty) {
      builder.emptyGeometry(Geom.lineString);
    } else {
      builder.lineString(array, type: coordType);
    }
  }

  void _buildPolygon(Coords coordType, Endian endian) {
    final array = _readLineStringArray(coordType, endian);
    if (conf.buildEmptyGeometries && array.isEmpty) {
      builder.emptyGeometry(Geom.polygon);
    } else {
      builder.polygon(array, type: coordType);
    }
  }

  void _buildMultiPoint(Coords coordType, Endian endian) {
    final array =
        _readPointArray(coordType, endian, requireHeaderForItems: true);
    if (conf.buildEmptyGeometries && array.isEmpty) {
      builder.emptyGeometry(Geom.multiPoint);
    } else {
      builder.multiPoint(array, type: coordType);
    }
  }

  void _buildMultiLineString(Coords coordType, Endian endian) {
    final array =
        _readLineStringArray(coordType, endian, requireHeaderForItems: true);
    if (conf.buildEmptyGeometries && array.isEmpty) {
      builder.emptyGeometry(Geom.multiLineString);
    } else {
      builder.multiLineString(array, type: coordType);
    }
  }

  void _buildMultiPolygon(Coords coordType, Endian endian) {
    final array =
        _readPolygonArray(coordType, endian, requireHeaderForItems: true);
    if (conf.buildEmptyGeometries && array.isEmpty) {
      builder.emptyGeometry(Geom.multiPolygon);
    } else {
      builder.multiPolygon(array, type: coordType);
    }
  }

  Endian _readByteOrder() {
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

  List<double> _readPoint(Coords coordType, Endian endian) {
    // all points has at least x and y values
    final x = buffer.readFloat64(endian);
    final y = buffer.readFloat64(endian);

    // by coordinate type create and return position as iterable of coordinates
    switch (coordType) {
      case Coords.xy:
        return [x, y];
      case Coords.xyz:
        return [x, y, buffer.readFloat64(endian)];
      case Coords.xym:
        return [x, y, 0, buffer.readFloat64(endian)];
      case Coords.xyzm:
        return [x, y, buffer.readFloat64(endian), buffer.readFloat64(endian)];
    }
  }

  List<Iterable<double>> _readPointArray(
    Coords coordType,
    Endian endian, {
    bool requireHeaderForItems = false,
  }) {
    // read number of points
    final numPoints = buffer.readUint32(endian);

    // return a generated list of points
    if (requireHeaderForItems) {
      return List<Iterable<double>>.generate(
        numPoints,
        (_) {
          // read byte order + type, expect point geom, and return coord type
          final pointEndian = _readByteOrder();
          final pointCoordType = _readCoordTypeAndExpectGeomType(
            Geom.point,
            pointEndian,
          );
          // read point and add it to a list to be generated
          return _readPoint(pointCoordType, pointEndian);
        },
        growable: false,
      );
    } else {
      return List<Iterable<double>>.generate(
        numPoints,
        (_) {
          // read point and add it to a list to be generated
          return _readPoint(coordType, endian);
        },
        growable: false,
      );
    }
  }

  List<Iterable<Iterable<double>>> _readLineStringArray(
    Coords coordType,
    Endian endian, {
    bool requireHeaderForItems = false,
  }) {
    // read number of line string (or liner rings)
    final numLineStrings = buffer.readUint32(endian);

    // return a generated list of line strings (or linear rings)
    if (requireHeaderForItems) {
      return List<Iterable<Iterable<double>>>.generate(
        numLineStrings,
        (_) {
          // read byte order + type, expect line string, and return coord type
          final lineStringEndian = _readByteOrder();
          final lineStringCoordType = _readCoordTypeAndExpectGeomType(
            Geom.lineString,
            lineStringEndian,
          );

          // read points of line string and add it to a list to be generated
          return _readPointArray(lineStringCoordType, lineStringEndian);
        },
        growable: false,
      );
    } else {
      return List<Iterable<Iterable<double>>>.generate(
        numLineStrings,
        (_) {
          // read points of line string and add it to a list to be generated
          return _readPointArray(coordType, endian);
        },
        growable: false,
      );
    }
  }

  List<Iterable<Iterable<Iterable<double>>>> _readPolygonArray(
    Coords coordType,
    Endian endian, {
    bool requireHeaderForItems = false,
  }) {
    // read number of polygons
    final numPolygons = buffer.readUint32(endian);

    // return a generated list of polygons
    if (requireHeaderForItems) {
      return List<Iterable<Iterable<Iterable<double>>>>.generate(
        numPolygons,
        (_) {
          // read byte order + type, expect polygon, and return coord type
          final polygonEndian = _readByteOrder();
          final polygonCoordType = _readCoordTypeAndExpectGeomType(
            Geom.polygon,
            polygonEndian,
          );

          // read linear rings of polygon + add it to a list to be generated
          return _readLineStringArray(polygonCoordType, polygonEndian);
        },
        growable: false,
      );
    } else {
      return List<Iterable<Iterable<Iterable<double>>>>.generate(
        numPolygons,
        (_) {
          // read linear rings of polygon + add it to a list to be generated
          return _readLineStringArray(coordType, endian);
        },
        growable: false,
      );
    }
  }
}
