// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'wkt_format.dart';

class _WktGeometryTextDecoder implements ContentDecoder {
  final GeometryContent builder;
  final CoordRefSys? crs;
  final bool singlePrecision;
  final Map<String, dynamic>? options;

  _WktGeometryTextDecoder(
    this.builder, {
    this.crs,
    // ignore: unused_element
    this.singlePrecision = false,
    this.options,
  });

  @override
  void decodeBytes(Uint8List source) => decodeText(utf8.decode(source));

  @override
  void decodeText(String source) {
    try {
      // decode the geometry object at given [source] string
      _parseGeometry(source.trim().toUpperCase(), builder);
    } on FormatException {
      rethrow;
    } catch (err) {
      // Errors might occur when casting data from external sources to
      // List<double>. We want to throw FormatException to clients however.
      throw FormatException('Not valid GeoJSON data (error: $err)');
    }
  }

  @override
  void decodeData(dynamic source) => decodeText(source.toString());

  void _parseGeometry(String text, GeometryContent builder) {
    for (var type = 0; type < _types.length; type++) {
      if (text.startsWith(_types[type])) {
        var i = _types[type].length;
        var expectM = false;
        var expectZ = false;
        while (i < text.length) {
          final c = text[i];
          switch (c) {
            case 'M':
              expectM = true;
              break;
            case 'Z':
              expectZ = true;
              break;
            case 'E':
              if (text.startsWith('EMPTY', i)) {
                switch (type) {
                  case 0: // POINT
                    builder.emptyGeometry(Geom.point);
                    return;
                  case 1: // LINESTRING
                    builder.emptyGeometry(Geom.lineString);
                    return;
                  case 2: // POLYGON
                    builder.emptyGeometry(Geom.polygon);
                    return;
                  case 3: // MULTIPOINT
                    builder.emptyGeometry(Geom.multiPoint);
                    return;
                  case 4: // MULTILINESTRING
                    builder.emptyGeometry(Geom.multiLineString);
                    return;
                  case 5: // MULTIPOLYGON
                    builder.emptyGeometry(Geom.multiPolygon);
                    return;
                  default: // case 6: // GEOMETRYCOLLECTION
                    builder.emptyGeometry(Geom.geometryCollection);
                    return;
                }
              } else {
                throw _invalidWkt(text);
              }
            case '(':
              if (text[text.length - 1] == ')') {
                final data = text.substring(i + 1, text.length - 1);
                final coordsType = _coordType(expectZ, expectM);
                switch (type) {
                  case 0: // POINT
                    builder.point(
                      _parsePosition(data, coordsType),
                    );
                    return;
                  case 1: // LINESTRING
                    builder.lineString(
                      _parsePositionSeries(data, coordsType),
                    );
                    return;
                  case 2: // POLYGON
                    builder.polygon(
                      _parsePositionSeriesArray(data, coordsType),
                    );
                    return;
                  case 3: // MULTIPOINT
                    builder.multiPoint(
                      _parsePositionArray(data, coordsType),
                    );
                    return;
                  case 4: // MULTILINESTRING
                    builder.multiLineString(
                      _parsePositionSeriesArray(data, coordsType),
                    );
                    return;
                  case 5: // MULTIPOLYGON
                    builder.multiPolygon(
                      _parsePositionSeriesArrayArray(data, coordsType),
                    );
                    return;
                  case 6: // GEOMETRYCOLLECTION
                    builder.geometryCollection(
                      (geom) => _parseGeometryCollection(data, geom, crs),
                      type: coordsType,
                    );
                    return;
                }
              } else {
                throw _invalidWkt(text);
              }
              break;
            default:
              if (!_isBlank(c)) throw _invalidWkt(text);
          }
          i++;
        }
        break;
      }
    }
    throw _invalidWkt(text);
  }

  /// Parses a position from [text] with coordinates separated by white space.
  Position _parsePosition(String text, Coords coordsType) {
    final dim = coordsType.coordinateDimension;
    final parts = _omitParenthesis(text.trim()).split(_splitByWhitespace);
    if (parts.length != dim) {
      throw _invalidCoords(text);
    }
    return parsePosition(
      parts,
      type: coordsType,
      singlePrecision: singlePrecision,
    );
  }

  /// Parses a position from [text] with coordinates separated by white
  /// space and sets position coordinates to the [target] list at [offset].
  void _parsePositionTo(String text, int dim, List<double> target, int offset) {
    final parts = _omitParenthesis(text.trim()).split(_splitByWhitespace);
    if (parts.length != dim) {
      throw _invalidCoords(text);
    }
    for (var i = 0; i < dim; i++) {
      target[offset + i] = double.parse(parts[i]);
    }
  }

  /// Parses an array of positions.
  List<Position> _parsePositionArray(String text, Coords coordsType) {
    final positions = text.split(',');
    return positions
        .map((pos) => _parsePosition(pos, coordsType))
        .toList(growable: false);
  }

  /// Parses a series of positions.
  PositionSeries _parsePositionSeries(String text, Coords coordsType) {
    final dim = coordsType.coordinateDimension;
    final positions = text.split(',');
    final len = positions.length;
    final array =
        singlePrecision ? Float32List(len * dim) : Float64List(len * dim);
    for (var i = 0; i < len; i++) {
      _parsePositionTo(positions[i], dim, array, i * dim);
    }
    return PositionSeries.view(array, type: coordsType);
  }

  /// Parses an array of series of positions.
  List<PositionSeries> _parsePositionSeriesArray(
    String text,
    Coords coordsType,
  ) {
    final list = <PositionSeries>[];

    var ls = 0;
    while (ls < text.length) {
      if (text[ls] == '(') {
        final le = text.indexOf(')', ls);
        if (le == -1) {
          throw _invalidWkt(text);
        } else {
          list.add(
            _parsePositionSeries(
              text.substring(ls + 1, le),
              coordsType,
            ),
          );
          ls = le;
        }
      }
      ls++;
    }

    return list;
  }

  /// Parses an array of arrays of series of positions.
  List<List<PositionSeries>> _parsePositionSeriesArrayArray(
    String text,
    Coords coordsType,
  ) {
    final polygons = <List<PositionSeries>>[];

    var ps = 0;
    while (ps < text.length) {
      if (text[ps] == '(') {
        final lineStrings = <PositionSeries>[];
        var ls = ps + 1;
        while (ls < text.length) {
          if (text[ls] == ')') {
            break;
          } else if (text[ls] == '(') {
            final le = text.indexOf(')', ls);
            if (le == -1) {
              throw _invalidWkt(text);
            } else {
              lineStrings.add(
                _parsePositionSeries(
                  text.substring(ls + 1, le),
                  coordsType,
                ),
              );
              ls = le;
            }
          }
          ls++;
        }
        final pe = text.indexOf(')', ls);
        if (pe == -1) {
          throw _invalidWkt(text);
        } else {
          polygons.add(lineStrings);
          ps = pe;
        }
      }
      ps++;
    }

    return polygons;
  }

  /// Parses a geometry collection from [text], parsed geometries included to a
  /// collection are sent to [builder].
  ///
  /// Optional [rangeStart] and [rangeLimit] parameters specify start offset and
  /// optional limit count specifying a geometry object range to be returned on
  /// a collection.
  void _parseGeometryCollection(
    String text,
    GeometryContent builder,
    CoordRefSys? crs, {
    int? rangeStart,
    int? rangeLimit,
  }) {
    if (rangeLimit == null || rangeLimit > 0) {
      var startChar = 0;
      var tokenIndex = 0;
      var countAdded = 0;
      while ((startChar = _findWktTokenStart(text, offset: startChar)) != -1) {
        final endChar = _findWktTokenEnd(text, startChar);
        if (endChar > startChar) {
          if (rangeStart == null || tokenIndex >= rangeStart) {
            _parseGeometry(text.substring(startChar, endChar), builder);
            countAdded++;
            if (rangeLimit != null && countAdded >= rangeLimit) {
              break;
            }
          }
          startChar = endChar;
          tokenIndex++;
        } else {
          throw _invalidWkt(text);
        }
      }
    }
  }
}

const _types = <String>[
  'POINT',
  'LINESTRING',
  'POLYGON',
  'MULTIPOINT',
  'MULTILINESTRING',
  'MULTIPOLYGON',
  'GEOMETRYCOLLECTION',
];

Coords _coordType(bool expectZ, bool expectM) => expectZ
    ? (expectM ? Coords.xyzm : Coords.xyz)
    : (expectM ? Coords.xym : Coords.xy);

bool _isBlank(String str) => str.trim().isEmpty;

final _splitByWhitespace = RegExp(r'\s+');

/// Create an exception telling [coords] text is invalid.
FormatException _invalidCoords(String coords) =>
    FormatException('Invalid coords: $coords');

/// Create an exception telling [wkt] text is invalid.
FormatException _invalidWkt(String wkt) => FormatException('Invalid wkt: $wkt');

String _omitParenthesis(String str) => str.startsWith('(') && str.endsWith(')')
    ? str.substring(1, str.length - 1)
    : str;

int _findWktTokenStart(String text, {int offset = 0}) {
  final len = text.length;
  var i = offset;
  while (i < len) {
    final c = text[i];
    if (_isBlank(c) || c == ',') {
      i++;
    } else {
      return i;
    }
  }
  return -1;
}

int _findWktTokenEnd(String text, int start) {
  final len = text.length;
  var i = start;
  var depth = 0;
  while (i < len) {
    final c = text[i];
    if (c == '(') {
      depth++;
    } else if (c == ')') {
      depth--;
      if (depth == 0) {
        // got last ")" in token like "POLYGON ((3 1, 4 4, 2 4, 1 2, 3 1))"
        // include that last ")"
        return i + 1;
      }
    } else if (c == ',') {
      if (depth == 0) {
        // got separating "," between token, do not include
        return i;
      }
    } else if (c == 'E') {
      if (text.startsWith('EMPTY', i)) {
        // propably end part of something like "POINT EMPTY"
        return i + 5;
      }
    }
    i++;
  }
  return i; // end of string, i == len + 1, return as end
}
