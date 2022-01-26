// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/schema.dart';
import '/src/utils/num.dart';

import 'coordinate_writer.dart';

/// A mixin specifying methods to format objects with coordinate data.
mixin CoordinateFormat {
  /// Returns a writer formatting string representations of coordinate data.
  ///
  /// When an optional [buffer] is given, then representations are written into
  /// it (without clearing any content it might already contain).
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// After writing some objects with coordinate data into a writer, the string
  /// representation can be accessed using `toString()` of it (or via [buffer]
  /// when such is given).
  CoordinateWriter text({StringSink? buffer, int? decimals});
}

/// The default format for formatting objects with coordinate data.
///
/// Rules applied by the format are aligned with GeoJSON.
///
/// Examples:
/// * point (x, y): `10.1,20.2`
/// * point (x, y, m) or (x, y, z): `10.1,20.2,30.3`
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

/// The WKT (like) format for formatting objects with coordinate data.
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

/// The WKT format for formatting objects with coordinate data.
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

class _DefaultFormat with CoordinateFormat {
  const _DefaultFormat();

  @override
  CoordinateWriter text({StringSink? buffer, int? decimals}) =>
      _DefaultTextWriter(buffer: buffer, decimals: decimals);
}

class _WktLikeFormat with CoordinateFormat {
  const _WktLikeFormat();

  @override
  CoordinateWriter text({StringSink? buffer, int? decimals}) =>
      _WktLikeTextWriter(buffer: buffer, decimals: decimals);
}

class _WktFormat with CoordinateFormat {
  const _WktFormat();

  @override
  CoordinateWriter text({StringSink? buffer, int? decimals}) =>
      _WktTextWriter(buffer: buffer, decimals: decimals);
}

abstract class _BaseTextWriter implements CoordinateWriter {
  _BaseTextWriter({StringSink? buffer, this.decimals})
      : _buffer = buffer ?? StringBuffer();

  final StringSink _buffer;
  final int? decimals;

  final List<bool> _hasItemsOnLevel = List.of([false]);
  final List<bool> _isCoordArrayOnLevel = List.of([false]);

  // no need for stack for these, as applicable only on leaf geometry elements
  bool? _askToPrintZ;
  bool? _askToPrintM;
  bool? _allowToPrintZ;
  bool? _allowToPrintM;

  @override
  String toString() => _buffer.toString();

  void _startGeometry({
    required bool isOutputLevelled,
    bool? is3D,
    bool? hasM,
  }) {
    if (isOutputLevelled) {
      _hasItemsOnLevel.add(false);
      _isCoordArrayOnLevel.add(false);
    }
    _askToPrintZ = is3D;
    _askToPrintM = hasM;
  }

  void _endGeometry({required bool isOutputLevelled}) {
    _askToPrintZ = null;
    _askToPrintM = null;
    _allowToPrintZ = null;
    _allowToPrintM = null;
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

  void _printPoint(
    String delimiter,
    num x,
    num y,
    num? z,
    num? m,
  ) {
    final hasZ = _askToPrintZ ?? z != null;
    final hasM = _askToPrintM ?? m != null;
    if (_allowToPrintZ == null && hasZ) {
      _allowToPrintZ = hasZ;
    }
    if (_allowToPrintM == null && hasM) {
      _allowToPrintZ ??= false;
      _allowToPrintM = hasM;
    }
    final printM = (_allowToPrintM ?? false) && hasM;
    final printZ = (_allowToPrintZ ?? false) && (hasZ || hasM);
    final dec = decimals;
    if (dec != null) {
      _buffer
        ..write(toStringAsFixedWhenDecimals(x, dec))
        ..write(delimiter)
        ..write(toStringAsFixedWhenDecimals(y, dec));
      if (printZ) {
        _buffer
          ..write(delimiter)
          ..write(toStringAsFixedWhenDecimals(z ?? 0.0, dec));
      }
      if (printM) {
        _buffer
          ..write(delimiter)
          ..write(toStringAsFixedWhenDecimals(m ?? 0.0, dec));
      }
    } else {
      _buffer
        ..write(x)
        ..write(delimiter)
        ..write(y);
      if (printZ) {
        _buffer
          ..write(delimiter)
          ..write(z ?? 0.0);
      }
      if (printM) {
        _buffer
          ..write(delimiter)
          ..write(m ?? 0.0);
      }
    }
  }

  @override
  void geometry(Geom type, {bool? is3D, bool? hasM}) {
    _startGeometry(isOutputLevelled: false, is3D: is3D, hasM: hasM);
  }

  @override
  void geometryEnd() {
    _endGeometry(isOutputLevelled: false);
  }

  @override
  void emptyGeometry(Geom type) {
    // nop
  }
}

// Implementation for the "default" format -------------------------------------

class _DefaultTextWriter extends _BaseTextWriter {
  _DefaultTextWriter({StringSink? buffer, int? decimals})
      : super(buffer: buffer, decimals: decimals);

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
    _printPoint(',', minX, minY, minZ, minM);
    _buffer.write(',');
    _printPoint(',', maxX, maxY, maxZ, maxM);
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
    _printPoint(',', x, y, z, m);
    if (notAtRoot) {
      _buffer.write(']');
    }
  }
}

// Implementation for the "wkt like" format ------------------------------------

class _WktLikeTextWriter extends _BaseTextWriter {
  _WktLikeTextWriter({StringSink? buffer, int? decimals})
      : super(buffer: buffer, decimals: decimals);

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
    _printPoint(' ', minX, minY, minZ, minM);
    _buffer.write(',');
    _printPoint(' ', maxX, maxY, maxZ, maxM);
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
    _printPoint(' ', x, y, z, m);
    if (notAtRootOrAtCoordArray) {
      _buffer.write(')');
    }
  }
}

// Implementation for the "wkt" format -----------------------------------------

class _WktTextWriter extends _WktLikeTextWriter {
  _WktTextWriter({StringSink? buffer, int? decimals})
      : super(buffer: buffer, decimals: decimals);

  @override
  void geometry(Geom type, {bool? is3D, bool? hasM}) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _startGeometry(isOutputLevelled: true, is3D: is3D, hasM: hasM);
    _buffer.write(type.nameWkt);
    if (is3D != null && is3D) {
      if (hasM != null && hasM) {
        _buffer.write(' ZM');
      } else {
        _buffer.write(' Z');
      }
    } else {
      if (hasM != null && hasM) {
        _buffer.write(' M');
      }
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
    final is3D = minZ != null && maxZ != null;
    final hasM = minM != null && maxM != null;
    final midZ = is3D ? 0.5 * minZ! + 0.5 * maxZ! : null;
    final midM = hasM ? 0.5 * minM! + 0.5 * maxM! : null;
    this
      ..geometry(Geom.polygon, is3D: is3D, hasM: hasM)
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
