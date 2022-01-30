// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/codes.dart';
import '/src/aspects/encode.dart';
import '/src/utils/num.dart';

import 'geometry_format.dart';

/// A mixin for geospatial features (with geometries and coordinates) format.
mixin FeaturesFormat implements GeometryFormat {}

/// The default format for geospatial features.
///
/// Rules applied by the format are aligned with GeoJSON.
///
/// Examples:
/// * point (x, y): `10.1,20.2`
/// * point (x, y, z): `10.1,20.2,30.3`
/// * point (x, y, m) with z formatted as 0: `10.1,20.2,0,40.4`
/// * point (x, y, z, m): `10.1,20.2,30.3,40.4`
/// * geopoint (lon, lat): `10.1,20.2`
/// * bounds (min-x, min-y, max-x, max-y): `10.1,10.1,20.2,20.2`
/// * bounds (min-x, min-y, min-z, max-x, max-y, maz-z):
///   * `10.1,10.1,10.1,20.2,20.2,20.2`
/// * point series, line string, multi point (with 2D points):
///   * `[10.1,10.1],[20.2,20.2],[30.3,30.3]`
/// * polygon, multi line string (with 2D points):
///   * `[[35,10],[45,45],[15,40],[10,20],[35,10]]`
/// * multi polygon (with 2D points):
///   * `[[[35,10],[45,45],[15,40],[10,20],[35,10]]]`
/// * coordinates for other geometries with similar principles
const defaultFormat = _DefaultFormat();

/// Returns a format for formatting geospatial features to GeoJSON.
///
/// Rules applied by the format conforms with the GeoJSON formatting of
/// coordinate lists and geometries.
///
/// Examples:
/// * point (x, y):
///   * `{"type":"Point","coordinates":[10.1,20.2]}`
/// * point (x, y, z):
///   * `{"type":"Point","coordinates":[10.1,20.2,30.3]}`
/// * geopoint (lon, lat):
///   * `{"type":"Point","coordinates":[10.1,20.2]}`
/// * bounds (min-x, min-y, max-x, max-y):
///   * `[10.1,10.1,20.2,20.2]`
/// * bounds (min-x, min-y, min-z, max-x, max-y, maz-z):
///   * `[100.1,10.1,10.1,20.2,20.2,20.2]`
/// * point series (with 2D points), not an independent GeoJSON geometry:
///   * `[[10.1,10.1],[20.2,20.2],[30.3,30.3]]`
///
/// Multi point (with 2D points):
/// `{"type":"MultiPoint","coordinates":[[10.1,10.1],[20.2,20.2],[30.3,30.3]]}`
///
/// Line string (with 2D points):
/// `{"type":"LineString","coordinates":[[10.1,10.1],[20.2,20.2],[30.3,30.3]]}`
///
/// Multi line string (with 2D points):
/// ```
///   {"type":"MultiLineString",
///    "coordinates":[[[10.1,10.1],[20.2,20.2],[30.3,30.3]]]}`
/// ```
///
/// Polygon (with 2D points):
/// ```
///   {"type":"Polygon",
///    "coordinates":[[[35,10],[45,45],[15,40],[10,20],[35,10]]]}`
/// ```
///
/// MultiPolygon (with 2D points):
/// ```
///   {"type":"Polygon",
///    "coordinates":[[[[35,10],[45,45],[15,40],[10,20],[35,10]]]]}`
/// ```
///
/// The GeoJSON specification about M coordinates:
///    "Implementations SHOULD NOT extend positions beyond three elements
///    because the semantics of extra elements are unspecified and
///    ambiguous.  Historically, some implementations have used a fourth
///    element to carry a linear referencing measure (sometimes denoted as
///    "M") or a numerical timestamp, but in most situations a parser will
///    not be able to properly interpret these values.  The interpretation
///    and meaning of additional elements is beyond the scope of this
///    specification, and additional elements MAY be ignored by parsers."
///
/// This implementation allows printing M coordinates, when available on source
/// data. Such M coordinate values are always formatted as "fourth element.".
/// However, it's possible that other implementations cannot read them:
/// * point (x, y, m), with z missing but formatted as 0, and m = 40.4:
///   * `{"type":"Point","coordinates":[10.1,20.2,0,40.4]}`
/// * point (x, y, z, m), with z = 30.3 and m = 40.4:
///   * `{"type":"Point","coordinates":[10.1,20.2,30.3,40.4]}`
///
/// However when [strict] is set to true, then M coordinates are ignored from
/// formatting.
FeaturesFormat geoJsonFormat({bool strict = false}) =>
    _GeoJsonFormat(strict: strict);

/// The WKT (like) format for geospatial features.
///
/// Rules applied by the format are aligned with WKT (Well-known text
/// representation of geometry) formatting of coordinate lists.
///
/// Examples:
/// * point (x, y): `10.1 20.2`
/// * point (x, y, m) or (x, y, z): `10.1 20.2 30.3`
/// * point (x, y, z, m): `10.1 20.2 30.3 40.4`
/// * geopoint (lon, lat): `10.1 20.2`
/// * bounds (min-x, min-y, max-x, max-y): `10.1 10.1,20.2 20.2`
/// * bounds (min-x, min-y, min-z, max-x, max-y, maz-z):
///   * `10.1 10.1 10.1,20.2 20.2 20.2`
/// * point series, line string, multi point (with 2D points):
///   * `10.1 10.1,20.2 20.2,30.3 30.3`
/// * polygon, multi line string (with 2D points):
///   * `(35 10,45 45,15 40,10 20,35 10)`
/// * multi polygon (with 2D points):
///   * `((35 10,45 45,15 40,10 20,35 10))`
/// * coordinates for other geometries with similar principles
///
/// Note that WKT does not specify bounding box formatting. In some applications
/// bounding boxes are formatted as polygons. An example presented above however
/// format bounding box as a point series of two points (min, max). See also
/// [wktFormat] that formats them as polygons.
const wktLikeFormat = _WktLikeFormat();

/// The WKT format for geospatial features.
///
/// Rules applied by the format conforms with WKT (Well-known text
/// representation of geometry) formatting of coordinate lists and geometries.
///
/// Examples:
/// * point (empty): `POINT EMPTY`
/// * point (x, y): `POINT(10.1 20.2)`
/// * point (x, y, z): `POINT Z(10.1 20.2 30.3)`
/// * point (x, y, m): `POINT M(10.1 20.2 30.3)`
/// * point (x, y, z, m): `POINT ZM(10.1 20.2 30.3 40.4)`
/// * geopoint (lon, lat): `POINT(10.1 20.2)`
/// * bounds (min-x, min-y, max-x, max-y) with values `10.1 10.1,20.2 20.2`:
///   * `POLYGON((10.1 10.1,20.2 10.1,20.2 20.2,10.1 20.2,10.1 10.1))`
/// * point series (with 2D points), not an independent WKT geometry:
///   * `10.1 10.1,20.2 20.2,30.3 30.3`
/// * multi point (with 2D points):
///   * `MULTIPOINT(10.1 10.1,20.2 20.2,30.3 30.3)`
/// * line string (with 2D points):
///   * `LINESTRING(10.1 10.1,20.2 20.2,30.3 30.3)`
/// * multi line string (with 2D points):
///   * `MULTILINESTRING((35 10,45 45,15 40,10 20,35 10))`
/// * polygon (with 2D points):
///   * `POLYGON((35 10,45 45,15 40,10 20,35 10))`
/// * multi polygon (with 2D points):
///   * `MULTIPOLYGON(((35 10,45 45,15 40,10 20,35 10)))`
/// * coordinates for other geometries with similar principles
///
/// Note that WKT does not specify bounding box formatting. Here bounding boxes
/// are formatted as polygons. See also [wktLikeFormat] that formats them as a
/// point series of two points (min, max).
const wktFormat = _WktFormat();

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

class _DefaultFormat with FeaturesFormat {
  const _DefaultFormat();

  @override
  GeometryWriter geometryToText({StringSink? buffer, int? decimals}) =>
      _DefaultTextWriter(buffer: buffer, decimals: decimals);
}

class _GeoJsonFormat with FeaturesFormat {
  const _GeoJsonFormat({this.strict = false});

  final bool strict;

  @override
  GeometryWriter geometryToText({StringSink? buffer, int? decimals}) =>
      _GeoJsonTextWriter(buffer: buffer, decimals: decimals, strict: strict);
}

class _WktLikeFormat with FeaturesFormat {
  const _WktLikeFormat();

  @override
  GeometryWriter geometryToText({StringSink? buffer, int? decimals}) =>
      _WktLikeTextWriter(buffer: buffer, decimals: decimals);
}

class _WktFormat with FeaturesFormat {
  const _WktFormat();

  @override
  GeometryWriter geometryToText({StringSink? buffer, int? decimals}) =>
      _WktTextWriter(buffer: buffer, decimals: decimals);
}

abstract class _BaseTextWriter implements GeometryWriter {
  _BaseTextWriter({StringSink? buffer, this.decimals})
      : _buffer = buffer ?? StringBuffer();

  final StringSink _buffer;
  final int? decimals;

  final List<bool> _hasItemsOnLevel = List.of([false]);
  final List<bool> _isCoordArrayOnLevel = List.of([false]);

  // no need for stack for these, as applicable only on leaf geometry elements
  Coords? _expectedType;

  void _startGeometry({required bool isOutputLevelled, Coords? expectedType}) {
    if (isOutputLevelled) {
      _hasItemsOnLevel.add(false);
      _isCoordArrayOnLevel.add(false);
    }
    _expectedType = expectedType;
  }

  void _endGeometry({required bool isOutputLevelled}) {
    _expectedType = null;
    if (isOutputLevelled) {
      _hasItemsOnLevel.removeLast();
      _isCoordArrayOnLevel.removeLast();
    }
  }

  void _startBoundedArray() {
    _hasItemsOnLevel.add(false);
    _isCoordArrayOnLevel.add(false);
  }

  void _endBoundedArray() {
    _hasItemsOnLevel.removeLast();
    _isCoordArrayOnLevel.removeLast();
  }

  void _startCoordArray() {
    _hasItemsOnLevel.add(false);
    _isCoordArrayOnLevel.add(true);
  }

  void _endCoordArray() {
    _hasItemsOnLevel.removeLast();
    _isCoordArrayOnLevel.removeLast();
  }

  bool get _notAtRoot => _hasItemsOnLevel.length > 1;

  bool get _atRootOrAtCoordArray =>
      _isCoordArrayOnLevel.length == 1 || _isCoordArrayOnLevel.last;

  bool _markItem() {
    final result = _hasItemsOnLevel.last;
    if (!result) {
      _hasItemsOnLevel[_hasItemsOnLevel.length - 1] = true;
    }
    return result;
  }

  @override
  void geometry(Geom type, {Coords? expectedType, WriteBounds? bounds}) {
    _startGeometry(isOutputLevelled: false, expectedType: expectedType);
  }

  @override
  void geometryEnd() {
    _endGeometry(isOutputLevelled: false);
  }

  @override
  void emptyGeometry(Geom type) {
    // nop
  }

  @override
  String toString() => _buffer.toString();
}

// Implementation for the "default" format -------------------------------------

class _DefaultTextWriter extends _BaseTextWriter {
  _DefaultTextWriter({StringSink? buffer, int? decimals, this.strict = false})
      : super(buffer: buffer, decimals: decimals);

  final bool strict;

  @override
  void boundedArray({int? expectedCount}) {
    if (_markItem()) {
      _buffer.write(',');
    }
    if (_notAtRoot) {
      _buffer.write('[');
    }
    _startBoundedArray();
  }

  @override
  void boundedArrayEnd() {
    _endBoundedArray();
    if (_notAtRoot) {
      _buffer.write(']');
    }
  }

  @override
  void coordArray({int? expectedCount}) {
    if (_markItem()) {
      _buffer.write(',');
    }
    if (_notAtRoot) {
      _buffer.write('[');
    }
    _startCoordArray();
  }

  @override
  void coordArrayEnd() {
    _endCoordArray();
    if (_notAtRoot) {
      _buffer.write(']');
    }
  }

  @override
  void coordBounds({
    required num minX,
    required num minY,
    num? minZ,
    num? minM,
    required num maxX,
    required num maxY,
    num? maxZ,
    num? maxM,
  }) {
    if (_markItem()) {
      _buffer.write(',');
    }
    final notAtRoot = _notAtRoot;
    if (notAtRoot) {
      _buffer.write('[');
    }
    _printPoint(minX, minY, minZ, minM);
    _buffer.write(',');
    _printPoint(maxX, maxY, maxZ, maxM);
    if (notAtRoot) {
      _buffer.write(']');
    }
  }

  @override
  void coordPoint({
    required num x,
    required num y,
    num? z,
    num? m,
  }) {
    if (_markItem()) {
      _buffer.write(',');
    }
    final notAtRoot = _notAtRoot;
    if (notAtRoot) {
      _buffer.write('[');
    }
    _printPoint(x, y, z, m);
    if (notAtRoot) {
      _buffer.write(']');
    }
  }

  void _printPoint(
    num x,
    num y,
    num? z,
    num? m,
  ) {
    // print M only in non-strict mode when
    // - explicitely asked or
    // - M exists and not explicitely denied
    final printM = !strict && (_expectedType?.hasM ?? m != null);
    // print Z when
    // - if M is printed too (M should be 4th element, so need Z as 3rd element)
    // - explicitely asked
    // - Z exists and not explicitely denied
    final printZ = printM || (_expectedType?.hasZ ?? z != null);
    final zValue = _expectedType?.hasZ ?? true ? z ?? 0 : 0;
    final dec = decimals;
    if (dec != null) {
      _buffer
        ..write(toStringAsFixedWhenDecimals(x, dec))
        ..write(',')
        ..write(toStringAsFixedWhenDecimals(y, dec));
      if (printZ) {
        _buffer
          ..write(',')
          ..write(toStringAsFixedWhenDecimals(zValue, dec));
      }
      if (printM) {
        _buffer
          ..write(',')
          ..write(toStringAsFixedWhenDecimals(m ?? 0, dec));
      }
    } else {
      _buffer
        ..write(x)
        ..write(',')
        ..write(y);
      if (printZ) {
        _buffer
          ..write(',')
          ..write(zValue);
      }
      if (printM) {
        _buffer
          ..write(',')
          ..write(m ?? 0);
      }
    }
  }
}

// Implementation for the "GeoJSON" format -------------------------------------

class _GeoJsonTextWriter extends _DefaultTextWriter {
  _GeoJsonTextWriter({StringSink? buffer, int? decimals, bool strict = false})
      : super(buffer: buffer, decimals: decimals, strict: strict);

  _GeoJsonTextWriter _subWriter() =>
      _GeoJsonTextWriter(buffer: _buffer, decimals: decimals, strict: strict);

  @override
  void geometry(Geom type, {Coords? expectedType, WriteBounds? bounds}) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _startGeometry(isOutputLevelled: true, expectedType: expectedType);
    _buffer
      ..write('{"type":"')
      ..write(type.nameGeoJson)
      ..write('"');
    if (bounds != null) {
      _buffer.write(',"bbox"=[');
      bounds.call(_subWriter());
      _buffer.write(']');
    }
    _buffer.write(
      type == Geom.geometryCollection ? ',"geometries":' : ',"coordinates":',
    );
  }

  @override
  void geometryEnd() {
    _buffer.write('}');
    _endGeometry(isOutputLevelled: true);
  }

  @override
  void emptyGeometry(Geom type) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _buffer
      ..write('{"type":"')
      ..write(type.nameGeoJson)
      ..write(
        type == Geom.geometryCollection
            ? '","geometries":[]}'
            // TODO(x): check how empty geometries should be written?
            : '","coordinates":[]}',
      );
  }
}

// Implementation for the "wkt like" format ------------------------------------

class _WktLikeTextWriter extends _BaseTextWriter {
  _WktLikeTextWriter({StringSink? buffer, int? decimals})
      : super(buffer: buffer, decimals: decimals);

  // no need for stack for these, as applicable only on leaf geometry elements
  bool? _allowToPrintZ;
  bool? _allowToPrintM;

  @override
  void boundedArray({int? expectedCount}) {
    if (_markItem()) {
      _buffer.write(',');
    }
    if (_notAtRoot) {
      _buffer.write('(');
    }
    _startBoundedArray();
  }

  @override
  void boundedArrayEnd() {
    _endBoundedArray();
    if (_notAtRoot) {
      _buffer.write(')');
    }
  }

  @override
  void coordArray({int? expectedCount}) {
    if (_markItem()) {
      _buffer.write(',');
    }
    if (_notAtRoot) {
      _buffer.write('(');
    }
    _startCoordArray();
  }

  @override
  void coordArrayEnd() {
    _endCoordArray();
    if (_notAtRoot) {
      _buffer.write(')');
    }
  }

  @override
  void coordBounds({
    required num minX,
    required num minY,
    num? minZ,
    num? minM,
    required num maxX,
    required num maxY,
    num? maxZ,
    num? maxM,
  }) {
    if (_markItem()) {
      _buffer.write(',');
    }
    final notAtRoot = _notAtRoot;
    if (notAtRoot) {
      _buffer.write('(');
    }
    _printPoint(minX, minY, minZ, minM);
    _buffer.write(',');
    _printPoint(maxX, maxY, maxZ, maxM);
    if (notAtRoot) {
      _buffer.write(')');
    }
  }

  @override
  void coordPoint({
    required num x,
    required num y,
    num? z,
    num? m,
  }) {
    if (_markItem()) {
      _buffer.write(',');
    }
    final notAtRootOrAtCoordArray = !_atRootOrAtCoordArray;
    if (notAtRootOrAtCoordArray) {
      _buffer.write('(');
    }
    _printPoint(x, y, z, m);
    if (notAtRootOrAtCoordArray) {
      _buffer.write(')');
    }
  }

  @override
  void _endGeometry({required bool isOutputLevelled}) {
    _allowToPrintZ = null;
    _allowToPrintM = null;
    super._endGeometry(isOutputLevelled: isOutputLevelled);
  }

  void _printPoint(
    num x,
    num y,
    num? z,
    num? m,
  ) {
    // check whether explicitely asked printing or value exists
    final hasZ = _expectedType?.hasZ ?? z != null;
    final hasM = _expectedType?.hasM ?? m != null;
    // "allow" variable are analyzed only once for point coords of a geometry
    if (_allowToPrintZ == null && hasZ) {
      _allowToPrintZ = hasZ;
    }
    if (_allowToPrintM == null && hasM) {
      _allowToPrintZ ??= false;
      _allowToPrintM = hasM;
    }
    // print M if it's allowed for this geometry and there is M or it's asked
    final printM = (_allowToPrintM ?? false) && hasM;
    // print Z if it's allowed for this geometry and there is Z or M
    final printZ = (_allowToPrintZ ?? false) && (hasZ || hasM);
    final dec = decimals;
    if (dec != null) {
      _buffer
        ..write(toStringAsFixedWhenDecimals(x, dec))
        ..write(' ')
        ..write(toStringAsFixedWhenDecimals(y, dec));
      if (printZ) {
        _buffer
          ..write(' ')
          ..write(toStringAsFixedWhenDecimals(z ?? 0, dec));
      }
      if (printM) {
        _buffer
          ..write(' ')
          ..write(toStringAsFixedWhenDecimals(m ?? 0, dec));
      }
    } else {
      _buffer
        ..write(x)
        ..write(' ')
        ..write(y);
      if (printZ) {
        _buffer
          ..write(' ')
          ..write(z ?? 0);
      }
      if (printM) {
        _buffer
          ..write(' ')
          ..write(m ?? 0);
      }
    }
  }
}

// Implementation for the "wkt" format -----------------------------------------

class _WktTextWriter extends _WktLikeTextWriter {
  _WktTextWriter({StringSink? buffer, int? decimals})
      : super(buffer: buffer, decimals: decimals);

  @override
  void geometry(Geom type, {Coords? expectedType, WriteBounds? bounds}) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _startGeometry(isOutputLevelled: true, expectedType: expectedType);
    _buffer.write(type.nameWkt);
    if (expectedType != null && expectedType != Coords.is2D) {
      _buffer
        ..write(' ')
        ..write(expectedType.specifierWkt);
    }
  }

  @override
  void geometryEnd() {
    _endGeometry(isOutputLevelled: true);
  }

  @override
  void emptyGeometry(Geom type) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _buffer
      ..write(type.nameWkt)
      ..write(' EMPTY');
  }

  @override
  void coordBounds({
    required num minX,
    required num minY,
    num? minZ,
    num? minM,
    required num maxX,
    required num maxY,
    num? maxZ,
    num? maxM,
  }) {
    // WKT does not recognize bounding box, so convert to POLYGON
    final hasZ = minZ != null && maxZ != null;
    final hasM = minM != null && maxM != null;
    final midZ = hasZ ? 0.5 * minZ! + 0.5 * maxZ! : null;
    final midM = hasM ? 0.5 * minM! + 0.5 * maxM! : null;
    this
      ..geometry(
        Geom.polygon,
        expectedType:
            _expectedType ?? CoordsExtension.select(hasZ: hasZ, hasM: hasM),
      )
      ..coordArray()
      ..coordArray()
      ..coordPoint(x: minX, y: minY, z: minZ, m: minM)
      ..coordPoint(x: maxX, y: minY, z: midZ, m: midM)
      ..coordPoint(x: maxX, y: maxY, z: maxZ, m: maxM)
      ..coordPoint(x: minX, y: maxY, z: midZ, m: midM)
      ..coordPoint(x: minX, y: minY, z: minZ, m: minM)
      ..coordArrayEnd()
      ..coordArrayEnd()
      ..geometryEnd();
  }
}
