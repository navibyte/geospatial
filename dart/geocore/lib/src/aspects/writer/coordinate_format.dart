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
/// format bounding box as a point series of two points (min, max).
const wktLikeFormat = _WktFormat();

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

class _DefaultFormat with CoordinateFormat {
  const _DefaultFormat();

  @override
  CoordinateWriter text({StringSink? buffer, int? decimals}) =>
      _DefaultTextWriter(buffer: buffer, decimals: decimals);
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

  @override
  String toString() => _buffer.toString();

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
}

class _DefaultTextWriter extends _BaseTextWriter {
  _DefaultTextWriter({StringSink? buffer, int? decimals})
      : super(buffer: buffer, decimals: decimals);

  @override
  void geometry(Geom type) {
    // nop
  }

  @override
  void geometryEnd() {
    // nop
  }

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
    _printPoint(x: minX, y: minY, z: minZ, m: minM);
    _buffer.write(',');
    _printPoint(x: maxX, y: maxY, z: maxZ, m: maxM);
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
    _printPoint(x: x, y: y, z: z, m: m);
    if (notAtRoot) {
      _buffer.write(']');
    }
  }

  void _printPoint({
    required num x,
    required num y,
    num? z,
    num? m,
  }) {
    final dec = decimals;
    if (dec != null) {
      _buffer
        ..write(toStringAsFixedWhenDecimals(x, dec))
        ..write(',')
        ..write(toStringAsFixedWhenDecimals(y, dec));
      if (z != null) {
        _buffer
          ..write(',')
          ..write(toStringAsFixedWhenDecimals(z, dec));
      }
      if (m != null) {
        _buffer
          ..write(',')
          ..write(toStringAsFixedWhenDecimals(m, dec));
      }
    } else {
      _buffer
        ..write(x)
        ..write(',')
        ..write(y);
      if (z != null) {
        _buffer
          ..write(',')
          ..write(z);
      }
      if (m != null) {
        _buffer
          ..write(',')
          ..write(m);
      }
    }
  }
}

class _WktTextWriter extends _BaseTextWriter {
  _WktTextWriter({StringSink? buffer, int? decimals})
      : super(buffer: buffer, decimals: decimals);

  @override
  void geometry(Geom type) {
    // nop
  }

  @override
  void geometryEnd() {
    // nop
  }

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
    _printPoint(x: minX, y: minY, z: minZ, m: minM);
    _buffer.write(',');
    _printPoint(x: maxX, y: maxY, z: maxZ, m: maxM);
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
    _printPoint(x: x, y: y, z: z, m: m);
    if (notAtRootOrAtCoordArray) {
      _buffer.write(')');
    }
  }

  void _printPoint({
    required num x,
    required num y,
    num? z,
    num? m,
  }) {
    final dec = decimals;
    if (dec != null) {
      _buffer
        ..write(toStringAsFixedWhenDecimals(x, dec))
        ..write(' ')
        ..write(toStringAsFixedWhenDecimals(y, dec));
      if (z != null) {
        _buffer
          ..write(' ')
          ..write(toStringAsFixedWhenDecimals(z, dec));
      }
      if (m != null) {
        _buffer
          ..write(' ')
          ..write(toStringAsFixedWhenDecimals(m, dec));
      }
    } else {
      _buffer
        ..write(x)
        ..write(' ')
        ..write(y);
      if (z != null) {
        _buffer
          ..write(' ')
          ..write(z);
      }
      if (m != null) {
        _buffer
          ..write(' ')
          ..write(m);
      }
    }
  }
}
