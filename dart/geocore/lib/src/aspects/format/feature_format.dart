// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/codes.dart';
import '/src/aspects/data.dart';
import '/src/aspects/encode.dart';
import '/src/utils/num.dart';

import 'geometry_format.dart';

/// A mixin for geospatial features (with geometries and coordinates) format.
mixin FeatureFormat implements GeometryFormat {
  /// Returns a writer formatting string representations of feature objects.
  ///
  /// When an optional [buffer] is given, then representations are written into
  /// it (without clearing any content it might already contain).
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// After writing some objects with coordinate data into a writer, the string
  /// representation can be accessed using `toString()` of it (or via [buffer]
  /// when such is given).
  FeatureWriter featuresToText({StringSink? buffer, int? decimals});
}

/// The default format for geometries (implements [GeometryFormat]).
///
/// Rules applied by the format are aligned with GeoJSON.
///
/// Examples:
/// * point (x, y): `10.1,20.2`
/// * point (x, y, z): `10.1,20.2,30.3`
/// * point (x, y, m) with z formatted as 0: `10.1,20.2,0,40.4`
/// * point (x, y, z, m): `10.1,20.2,30.3,40.4`
/// * box (min-x, min-y, max-x, max-y): `10.1,10.1,20.2,20.2`
/// * box (min-x, min-y, min-z, max-x, max-y, maz-z):
///   * `10.1,10.1,10.1,20.2,20.2,20.2`
/// * line string, multi point (with 2D points):
///   * `[10.1,10.1],[20.2,20.2],[30.3,30.3]`
/// * polygon, multi line string (with 2D points):
///   * `[[35,10],[45,45],[15,40],[10,20],[35,10]]`
/// * multi polygon (with 2D points):
///   * `[[[35,10],[45,45],[15,40],[10,20],[35,10]]]`
/// * coordinates for other geometries with similar principles
const defaultFormat = _DefaultFormat();

/// Returns a format for formatting geometries and features to GeoJSON.
///
/// This format implements [FeatureFormat] (that implements [GeometryFormat]).
///
/// Rules applied by the format conforms with the GeoJSON formatting of
/// coordinate lists and geometries.
///
/// Examples:
/// * point (x, y):
///   * `{"type":"Point","coordinates":[10.1,20.2]}`
/// * point (x, y, z):
///   * `{"type":"Point","coordinates":[10.1,20.2,30.3]}`
/// * box (min-x, min-y, max-x, max-y), as a property inside other object:
///   * `"bbox": [10.1,10.1,20.2,20.2]`
/// * box (min-x, min-y, min-z, max-x, max-y, maz-z), as a property:
///   * `"bbox": [10.1,10.1,10.1,20.2,20.2,20.2]`
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
///    "coordinates":[[[10.1,10.1],[20.2,20.2],[30.3,30.3]]]}
/// ```
///
/// Polygon (with 2D points):
/// ```
///   {"type":"Polygon",
///    "coordinates":[[[35,10],[45,45],[15,40],[10,20],[35,10]]]}
/// ```
///
/// MultiPolygon (with 2D points):
/// ```
///   {"type":"Polygon",
///    "coordinates":[[[[35,10],[45,45],[15,40],[10,20],[35,10]]]]}
/// ```
///
/// Feature:
/// ```
///   {"type": "Feature",
///    "id":1,
///    "properties": {"prop1": 100},
///    "geometry": {"type":"Point","coordinates":[10.1,20.2]}}
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
/// However when [ignoreMeasured] is set to true, then M coordinates are ignored
/// from formatting.
///
/// When [ignoreForeignMembers] is set to true, then such JSON elements that are
/// not described by the GeoJSON specification, are ignored. See the section 6.1
/// of the specifcation (RFC 7946).
FeatureFormat geoJsonFormat({
  bool ignoreMeasured = false,
  bool ignoreForeignMembers = false,
}) =>
    _GeoJsonFormat(
      ignoreMeasured: ignoreMeasured,
      ignoreForeignMembers: ignoreForeignMembers,
    );

/// The WKT (like) format for geometries (implements [GeometryFormat]).
///
/// Rules applied by the format are aligned with WKT (Well-known text
/// representation of geometry) formatting of coordinate lists.
///
/// Examples:
/// * point (x, y): `10.1 20.2`
/// * point (x, y, z): `10.1 20.2 30.3`
/// * point (x, y, z, m): `10.1 20.2 30.3 40.4`
/// * box (min-x, min-y, max-x, max-y): `10.1 10.1,20.2 20.2`
/// * box (min-x, min-y, min-z, max-x, max-y, maz-z):
///   * `10.1 10.1 10.1,20.2 20.2 20.2`
/// * line string, multi point (with 2D points):
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

/// The WKT format for geometries (implements [GeometryFormat]).
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
/// * box (min-x, min-y, max-x, max-y) with values `10.1 10.1,20.2 20.2`:
///   * `POLYGON((10.1 10.1,20.2 10.1,20.2 20.2,10.1 20.2,10.1 10.1))`
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
GeometryFormat wktFormat() => const _WktFormat();

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

class _DefaultFormat implements GeometryFormat {
  const _DefaultFormat();

  @override
  CoordinateWriter coordinatesToText({StringSink? buffer, int? decimals}) =>
      _DefaultTextWriter(buffer: buffer, decimals: decimals);

  @override
  GeometryWriter geometriesToText({StringSink? buffer, int? decimals}) =>
      _DefaultTextWriter(buffer: buffer, decimals: decimals);
}

class _GeoJsonFormat with FeatureFormat {
  const _GeoJsonFormat({
    this.ignoreMeasured = false,
    this.ignoreForeignMembers = false,
  });

  final bool ignoreMeasured;
  final bool ignoreForeignMembers;

  @override
  CoordinateWriter coordinatesToText({StringSink? buffer, int? decimals}) =>
      _GeoJsonTextWriter(
        buffer: buffer,
        decimals: decimals,
        ignoreMeasured: ignoreMeasured,
        ignoreForeignMembers: ignoreForeignMembers,
      );

  @override
  GeometryWriter geometriesToText({StringSink? buffer, int? decimals}) =>
      _GeoJsonTextWriter(
        buffer: buffer,
        decimals: decimals,
        ignoreMeasured: ignoreMeasured,
        ignoreForeignMembers: ignoreForeignMembers,
      );

  @override
  FeatureWriter featuresToText({StringSink? buffer, int? decimals}) =>
      _GeoJsonTextWriter(
        buffer: buffer,
        decimals: decimals,
        ignoreMeasured: ignoreMeasured,
        ignoreForeignMembers: ignoreForeignMembers,
      );
}

class _WktLikeFormat implements GeometryFormat {
  const _WktLikeFormat();

  @override
  CoordinateWriter coordinatesToText({StringSink? buffer, int? decimals}) =>
      _WktLikeTextWriter(buffer: buffer, decimals: decimals);

  @override
  GeometryWriter geometriesToText({StringSink? buffer, int? decimals}) =>
      _WktLikeTextWriter(buffer: buffer, decimals: decimals);
}

class _WktFormat implements GeometryFormat {
  const _WktFormat();

  @override
  CoordinateWriter coordinatesToText({StringSink? buffer, int? decimals}) =>
      _WktTextWriter(buffer: buffer, decimals: decimals);

  @override
  GeometryWriter geometriesToText({StringSink? buffer, int? decimals}) =>
      _WktTextWriter(buffer: buffer, decimals: decimals);
}

// Base implementation for writers ---------------------------------------------

enum _Container {
  root,
  featureCollection,
  feature,
  objectArray,
  geometry,
  coordArray,
  propertyMap,
  propertyArray,
}

abstract class _BaseTextWriter with GeometryWriter, CoordinateWriter {
  _BaseTextWriter({StringSink? buffer, this.decimals})
      : _buffer = buffer ?? StringBuffer();

  final StringSink _buffer;
  final int? decimals;

  final List<bool> _hasItemsOnLevel = List.of([false]);
  final List<_Container> _containerTypeOnLevel = List.of([_Container.root]);

  final List<Coords?> _coordTypes = [];

  void _startContainer(_Container type) {
    _hasItemsOnLevel.add(false);
    _containerTypeOnLevel.add(type);
  }

  void _endContainer() {
    _hasItemsOnLevel.removeLast();
    _containerTypeOnLevel.removeLast();
  }

  void _startCoordType(Coords? coordType) {
    _coordTypes.add(coordType);
  }

  void _endCoordType() {
    _coordTypes.removeLast();
  }

  bool get _atFeature => _containerTypeOnLevel.last == _Container.feature;

  bool get _atFeatureCollection {
    final last = _containerTypeOnLevel.last;
    if (last == _Container.featureCollection) {
      return true;
    }
    final len = _containerTypeOnLevel.length;
    if (last == _Container.objectArray && len >= 2) {
      final prev = _containerTypeOnLevel[len - 2];
      if (prev == _Container.featureCollection) {
        return true;
      }
    }
    return false;
  }

  bool get _notAtRoot => _hasItemsOnLevel.length > 1;

  bool get _atRootOrAtCoordArray =>
      _containerTypeOnLevel.length == 1 ||
      _containerTypeOnLevel.last == _Container.coordArray;

  bool _markItem() {
    final result = _hasItemsOnLevel.last;
    if (!result) {
      _hasItemsOnLevel[_hasItemsOnLevel.length - 1] = true;
    }
    return result;
  }

  void _startObjectArray({int? count}) {
    _startContainer(_Container.objectArray);
  }

  void _endObjectArray() {
    _endContainer();
  }

  bool _geometryBeforeCoordinates({
    required Geom type,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    _startCoordType(coordType);
    return true;
  }

  void _geometryAfterCoordinates() {
    _endCoordType();
  }

  @override
  void geometryWithPosition({
    required Geom type,
    required Position coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      type: type,
      name: name,
      coordType: coordType,
      bbox: bbox,
    )) {
      _coordPoint(
        x: coordinates.x,
        y: coordinates.y,
        z: coordinates.optZ,
        m: coordinates.optM,
      );
      _geometryAfterCoordinates();
    }
  }

  @override
  void geometryWithPositions1D({
    required Geom type,
    required Iterable<Position> coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      type: type,
      name: name,
      coordType: coordType,
      bbox: bbox,
    )) {
      _coordArray(count: coordinates.length);
      for (final pos in coordinates) {
        position(pos);
      }
      _coordArrayEnd();
      _geometryAfterCoordinates();
    }
  }

  @override
  void geometryWithPositions2D({
    required Geom type,
    required Iterable<Iterable<Position>> coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      type: type,
      name: name,
      coordType: coordType,
      bbox: bbox,
    )) {
      _coordArray(count: coordinates.length);
      for (final item in coordinates) {
        positions1D(item);
      }
      _coordArrayEnd();
      _geometryAfterCoordinates();
    }
  }

  @override
  void geometryWithPositions3D({
    required Geom type,
    required Iterable<Iterable<Iterable<Position>>> coordinates,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      type: type,
      name: name,
      coordType: coordType,
      bbox: bbox,
    )) {
      _coordArray(count: coordinates.length);
      for (final item in coordinates) {
        positions2D(item);
      }
      _coordArrayEnd();
      _geometryAfterCoordinates();
    }
  }

  @override
  void geometryCollection({
    required WriteGeometries geometries,
    int? count,
    String? name,
    Box? bbox,
  }) {
    _startCoordType(null);
    _startObjectArray(count: count);
    geometries.call(this);
    _endObjectArray();
    _endCoordType();
  }

  @override
  void emptyGeometry(Geom type, {String? name}) {
    // nop
  }

  void _coordArray({int? count});

  void _coordArrayEnd();

  void _coordPoint({
    required num x,
    required num y,
    num? z,
    num? m,
  });

  @override
  void position(Position coordinates) {
    _coordPoint(
      x: coordinates.x,
      y: coordinates.y,
      z: coordinates.optZ,
      m: coordinates.optM,
    );
  }

  @override
  void positions1D(Iterable<Position> coordinates) {
    _coordArray(count: coordinates.length);
    for (final pos in coordinates) {
      position(pos);
    }
    _coordArrayEnd();
  }

  @override
  void positions2D(Iterable<Iterable<Position>> coordinates) {
    _coordArray(count: coordinates.length);
    for (final item in coordinates) {
      positions1D(item);
    }
    _coordArrayEnd();
  }

  @override
  void positions3D(
    Iterable<Iterable<Iterable<Position>>> coordinates,
  ) {
    _coordArray(count: coordinates.length);
    for (final item in coordinates) {
      positions2D(item);
    }
    _coordArrayEnd();
  }

  @override
  String toString() => _buffer.toString();
}

// Writer for the "default" format ---------------------------------------------

class _DefaultTextWriter extends _BaseTextWriter {
  _DefaultTextWriter({
    StringSink? buffer,
    int? decimals,
    this.ignoreMeasured = false,
  }) : super(buffer: buffer, decimals: decimals);

  final bool ignoreMeasured;

  @override
  void _startObjectArray({int? count}) {
    if (_markItem()) {
      _buffer.write(',');
    }
    if (_notAtRoot) {
      _buffer.write('[');
    }
    _startContainer(_Container.objectArray);
  }

  @override
  void _endObjectArray() {
    _endContainer();
    if (_notAtRoot) {
      _buffer.write(']');
    }
  }

  @override
  void _coordArray({int? count}) {
    if (_markItem()) {
      _buffer.write(',');
    }
    if (_notAtRoot) {
      _buffer.write('[');
    }
    _startContainer(_Container.coordArray);
  }

  @override
  void _coordArrayEnd() {
    _endContainer();
    if (_notAtRoot) {
      _buffer.write(']');
    }
  }

  @override
  void box(Box box) {
    if (_markItem()) {
      _buffer.write(',');
    }
    final notAtRoot = _notAtRoot;
    if (notAtRoot) {
      _buffer.write('[');
    }
    _printPoint(box.minX, box.minY, box.minZ, box.minM);
    _buffer.write(',');
    _printPoint(box.maxX, box.maxY, box.maxZ, box.maxM);
    if (notAtRoot) {
      _buffer.write(']');
    }
  }

  @override
  void _coordPoint({
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
    // check optional expected coordinate type
    final coordType = _coordTypes.isNotEmpty ? _coordTypes.last : null;
    // print M only in non-strict mode when
    // - explicitely asked or
    // - M exists and not explicitely denied
    final printM = !ignoreMeasured && (coordType?.isMeasured ?? m != null);
    // print Z when
    // - if M is printed too (M should be 4th element, so need Z as 3rd element)
    // - explicitely asked
    // - Z exists and not explicitely denied
    final printZ = printM || (coordType?.is3D ?? z != null);
    final zValue = coordType?.is3D ?? true ? z ?? 0 : 0;
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

// Writer  for the "GeoJSON" format --------------------------------------------

class _GeoJsonTextWriter extends _DefaultTextWriter
    with FeatureWriter, PropertyWriter {
  _GeoJsonTextWriter({
    StringSink? buffer,
    int? decimals,
    bool ignoreMeasured = false,
    this.ignoreForeignMembers = false,
  }) : super(
          buffer: buffer,
          decimals: decimals,
          ignoreMeasured: ignoreMeasured,
        );

  final bool ignoreForeignMembers;

  _GeoJsonTextWriter _subWriter() => _GeoJsonTextWriter(
        buffer: _buffer,
        decimals: decimals,
        ignoreMeasured: ignoreMeasured,
      );

  @override
  bool _geometryBeforeCoordinates({
    required Geom type,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    if (ignoreForeignMembers &&
        _atFeature &&
        (name ?? 'geometry') != 'geometry') {
      return false;
    }
    if (_markItem()) {
      _buffer.write(',');
    }
    if (_atFeature) {
      _buffer.write(name == null ? '"geometry":' : '"$name":');
    }
    _startContainer(_Container.geometry);
    _startCoordType(coordType);
    _buffer
      ..write('{"type":"')
      ..write(type.nameGeoJson)
      ..write('"');
    if (bbox != null) {
      _buffer.write(',"bbox":[');
      _subWriter().box(bbox);
      _buffer.write(']');
    }
    _buffer.write(',"coordinates":');
    return true;
  }

  @override
  void _geometryAfterCoordinates() {
    _buffer.write('}');
    _endCoordType();
    _endContainer();
  }

  @override
  void geometryCollection({
    required WriteGeometries geometries,
    int? count,
    String? name,
    Box? bbox,
  }) {
    if (ignoreForeignMembers &&
        _atFeature &&
        (name ?? 'geometry') != 'geometry') {
      return;
    }
    if (_markItem()) {
      _buffer.write(',');
    }
    if (_atFeature) {
      _buffer.write(name == null ? '"geometry":' : '"$name":');
    }
    _startContainer(_Container.geometry);
    _startCoordType(null);
    _buffer.write('{"type":"GeometryCollection"');
    if (bbox != null) {
      _buffer.write(',"bbox":[');
      _subWriter().box(bbox);
      _buffer.write(']');
    }
    _buffer.write(',"geometries":');
    _startObjectArray(count: count);
    geometries.call(this);
    _endObjectArray();
    _buffer.write('}');
    _endCoordType();
    _endContainer();
  }

  @override
  void emptyGeometry(Geom type, {String? name}) {
    if (ignoreForeignMembers &&
        _atFeature &&
        (name ?? 'geometry') != 'geometry') {
      return;
    }
    if (_markItem()) {
      _buffer.write(',');
    }
    if (_atFeature) {
      // under "Feature" write empty geometry as `null` value
      _buffer.write(name == null ? '"geometry":null' : '"$name":null');
    } else {
      // elsewhere (than under "Feature") write Geometry element without data
      _buffer
        ..write('{"type":"')
        ..write(type.nameGeoJson)
        ..write(
          type == Geom.geometryCollection
              ? '","geometries":[]}'
              : '","coordinates":[]}',
        );
    }
  }

  @override
  void featureCollection({
    required WriteFeatures features,
    int? count,
    Box? bbox,
    WriteProperties? extra,
  }) {
    if (_atFeatureCollection) {
      return;
    }
    if (_markItem()) {
      _buffer.write(',');
    }
    _startContainer(_Container.featureCollection);
    _buffer.write('{"type":"FeatureCollection"');
    if (bbox != null) {
      _buffer.write(',"bbox":[');
      _subWriter().box(bbox);
      _buffer.write(']');
    }
    _buffer.write(',"features":');
    _startObjectArray(count: count);
    features.call(this);
    _endObjectArray();
    if (!ignoreForeignMembers && extra != null) {
      _markItem();
      extra.call(this);
    }
    _buffer.write('}');
    _endContainer();
  }

  @override
  void feature({
    Object? id,
    WriteGeometries? geometries,
    Map<String, Object?>? properties,
    Box? bbox,
    WriteProperties? extra,
  }) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _startContainer(_Container.feature);
    _buffer.write('{"type":"Feature"');
    if (id != null) {
      if (id is int) {
        _buffer
          ..write(',"id":')
          ..write(id);
      } else {
        _buffer
          ..write(',"id":"')
          ..write(id.toString())
          ..write('"');
      }
    }
    _markItem();
    if (bbox != null) {
      _buffer.write(',"bbox":[');
      _subWriter().box(bbox);
      _buffer.write(']');
    }
    if (geometries != null) {
      geometries.call(this);
    }
    _printMapEntryRecursive(
      'properties',
      properties ?? const <String, Object?>{},
    );
    if (!ignoreForeignMembers && extra != null) {
      extra.call(this);
    }
    _buffer.write('}');
    _endContainer();
  }

  @override
  void properties(String name, Map<String, Object?> map) {
    if (_atFeature && name == 'properties') {
      return;
    }
    _printMapEntryRecursive(name, map);
  }

  @override
  void property(String name, Object? value) {
    if (_atFeature && name == 'properties') {
      return;
    }
    _printMapEntryRecursive(name, value);
  }

  void _printMapEntryRecursive(String name, Object? value) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _buffer
      ..write('"')
      ..write(name)
      ..write('":');
    if (value is Map<String, Object?>) {
      _printMap(value);
    } else if (value is Iterable<Object?>) {
      _printArray(value);
    } else {
      _printValue(value);
    }
  }

  void _printArrayItemRecursive(Object? value) {
    if (_markItem()) {
      _buffer.write(',');
    }
    if (value is Map<String, Object?>) {
      _printMap(value);
    } else if (value is Iterable<Object?>) {
      _printArray(value);
    } else {
      _printValue(value);
    }
  }

  void _printMap(Map<String, Object?> map) {
    _startContainer(_Container.propertyMap);
    _buffer.write('{');
    for (final entry in map.entries) {
      _printMapEntryRecursive(entry.key, entry.value);
    }
    _buffer.write('}');
    _endContainer();
  }

  void _printArray(Iterable<Object?> array) {
    _startContainer(_Container.propertyArray);
    _buffer.write('[');
    for (final item in array) {
      _printArrayItemRecursive(item);
    }
    _buffer.write(']');
    _endContainer();
  }

  void _printValue(Object? value) {
    if (value == null || value is bool || value is num || value is BigInt) {
      _buffer.write(value.toString());
    } else {
      _buffer
        ..write('"')
        ..write(value.toString())
        ..write('"');
    }
  }
}

// Writer for the "wkt like" format --------------------------------------------

class _WktLikeTextWriter extends _BaseTextWriter {
  _WktLikeTextWriter({StringSink? buffer, int? decimals})
      : super(buffer: buffer, decimals: decimals);

  @override
  void _startObjectArray({int? count}) {
    if (_markItem()) {
      _buffer.write(',');
    }
    if (_notAtRoot) {
      _buffer.write('(');
    }
    _startContainer(_Container.objectArray);
  }

  @override
  void _endObjectArray() {
    _endContainer();
    if (_notAtRoot) {
      _buffer.write(')');
    }
  }

  @override
  void _coordArray({int? count}) {
    if (_markItem()) {
      _buffer.write(',');
    }
    if (_notAtRoot) {
      _buffer.write('(');
    }
    _startContainer(_Container.coordArray);
  }

  @override
  void _coordArrayEnd() {
    _endContainer();
    if (_notAtRoot) {
      _buffer.write(')');
    }
  }

  @override
  void box(Box box) {
    if (_markItem()) {
      _buffer.write(',');
    }
    final notAtRoot = _notAtRoot;
    if (notAtRoot) {
      _buffer.write('(');
    }
    _printPoint(box.minX, box.minY, box.minZ, box.minM);
    _buffer.write(',');
    _printPoint(box.maxX, box.maxY, box.maxZ, box.maxM);
    if (notAtRoot) {
      _buffer.write(')');
    }
  }

  @override
  void _coordPoint({
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

  void _printPoint(
    num x,
    num y,
    num? z,
    num? m,
  ) {
    // check optional expected coordinate type
    final coordType = _coordTypes.isNotEmpty ? _coordTypes.last : null;
    final bool printM;
    final bool printZ;
    final num zValue;
    if (coordType != null) {
      // coordinate type specified (in wkt specifiers Z, M or ZM)
      //
      // check whether explicitely asked printing
      printZ = coordType.is3D;
      printM = coordType.isMeasured;
      zValue = z ?? 0;
    } else {
      // coordinate type unspecified (z is 3rd if exists, m is 4th if exists)
      // (this is similar rule to GeoJSON format)
      //
      // print M when
      // - explicitely asked or
      // - M exists and not explicitely denied
      printM = coordType?.isMeasured ?? m != null;
      // print Z when
      // - if M is printed too (M should be 4th element, so need Z as 3rd)
      // - explicitely asked
      // - Z exists and not explicitely denied
      printZ = printM || (coordType?.is3D ?? z != null);
      zValue = coordType?.is3D ?? true ? z ?? 0 : 0;
    }
    final dec = decimals;
    if (dec != null) {
      _buffer
        ..write(toStringAsFixedWhenDecimals(x, dec))
        ..write(' ')
        ..write(toStringAsFixedWhenDecimals(y, dec));
      if (printZ) {
        _buffer
          ..write(' ')
          ..write(toStringAsFixedWhenDecimals(zValue, dec));
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
          ..write(zValue);
      }
      if (printM) {
        _buffer
          ..write(' ')
          ..write(m ?? 0);
      }
    }
  }
}

// Writer for the "wkt" format -------------------------------------------------

class _WktTextWriter extends _WktLikeTextWriter {
  _WktTextWriter({StringSink? buffer, int? decimals})
      : super(buffer: buffer, decimals: decimals);

  @override
  bool _geometryBeforeCoordinates({
    required Geom type,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _startContainer(_Container.geometry);
    _startCoordType(coordType);
    _buffer.write(type.nameWkt);
    if (coordType != null && coordType != Coords.xy) {
      _buffer
        ..write(' ')
        ..write(coordType.specifierWkt);
    }
    return true;
  }

  @override
  void _geometryAfterCoordinates() {
    _endCoordType();
    _endContainer();
  }

  @override
  void geometryCollection({
    required WriteGeometries geometries,
    int? count,
    String? name,
    Box? bbox,
  }) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _startContainer(_Container.geometry);
    _startCoordType(null);
    _buffer.write('GEOMETRYCOLLECTION');
    _startObjectArray(count: count);
    geometries.call(this);
    _endObjectArray();
    _endCoordType();
    _endContainer();
  }

  @override
  void emptyGeometry(Geom type, {String? name}) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _buffer
      ..write(type.nameWkt)
      ..write(' EMPTY');
  }

  @override
  void box(Box box) {
    // WKT does not recognize bounding box, so convert to POLYGON
    final hasZ = box.minZ != null && box.maxZ != null;
    final hasM = box.minM != null && box.maxM != null;
    final midZ = hasZ ? 0.5 * box.minZ! + 0.5 * box.maxZ! : null;
    final midM = hasM ? 0.5 * box.minM! + 0.5 * box.maxM! : null;
    // check optional expected coordinate type
    final coordType = _coordTypes.isNotEmpty
        ? _coordTypes.last
        : CoordsExtension.select(is3D: hasZ, isMeasured: hasM);
    // print polygon geometry
    if (_markItem()) {
      _buffer.write(',');
    }
    _startContainer(_Container.geometry);
    _startCoordType(coordType);
    _buffer.write(Geom.polygon.nameWkt);
    if (coordType != null && coordType != Coords.xy) {
      _buffer
        ..write(' ')
        ..write(coordType.specifierWkt);
    }
    _coordArray();
    _coordArray();
    _coordPoint(x: box.minX, y: box.minY, z: box.minZ, m: box.minM);
    _coordPoint(x: box.maxX, y: box.minY, z: midZ, m: midM);
    _coordPoint(x: box.maxX, y: box.maxY, z: box.maxZ, m: box.maxM);
    _coordPoint(x: box.minX, y: box.maxY, z: midZ, m: midM);
    _coordPoint(x: box.minX, y: box.minY, z: box.minZ, m: box.minM);
    _coordArrayEnd();
    _coordArrayEnd();
    _endCoordType();
    _endContainer();
  }
}
