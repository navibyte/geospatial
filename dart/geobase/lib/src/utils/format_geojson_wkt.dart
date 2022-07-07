// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:typed_data';

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/coordinates/base.dart';
import '/src/coordinates/projected.dart';
import '/src/utils/format_validation.dart';
import '/src/utils/num.dart';
import '/src/vector/content.dart';
import '/src/vector/encoding.dart';

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

abstract class _BaseTextWriter<T extends Object>
    with GeometryContent, CoordinateContent
    implements ContentEncoder<T> {
  _BaseTextWriter({StringSink? buffer, this.decimals})
      : _buffer = buffer ?? StringBuffer();

  final StringSink _buffer;
  final int? decimals;

  final List<bool> _hasItemsOnLevel = List.of([false]);
  final List<_Container> _containerTypeOnLevel = List.of([_Container.root]);

  final List<Coords?> _coordTypes = [];

  @override
  T get writer => this as T;

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
    Object? bbox,
  }) {
    _startCoordType(coordType);
    return true;
  }

  void _geometryAfterCoordinates() {
    _endCoordType();
  }

  @override
  void point(
    Object coordinates, {
    String? name,
    Coords? coordType,
  }) {
    if (_geometryBeforeCoordinates(
      type: Geom.point,
      name: name,
      coordType: coordType,
    )) {
      _coordPosition(coordinates);
      _geometryAfterCoordinates();
    }
  }

  @override
  void lineString(
    Iterable<Object> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      type: Geom.lineString,
      name: name,
      coordType: coordType,
      bbox: bbox,
    )) {
      _coordArray(count: coordinates.length);
      for (final pos in coordinates) {
        _coordPosition(pos);
      }
      _coordArrayEnd();
      _geometryAfterCoordinates();
    }
  }

  @override
  void polygon(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      type: Geom.polygon,
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
  void multiPoint(
    Iterable<Object> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      type: Geom.multiPoint,
      name: name,
      coordType: coordType,
      bbox: bbox,
    )) {
      _coordArray(count: coordinates.length);
      for (final pos in coordinates) {
        _coordPosition(pos);
      }
      _coordArrayEnd();
      _geometryAfterCoordinates();
    }
  }

  @override
  void multiLineString(
    Iterable<Iterable<Object>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      type: Geom.multiLineString,
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
  void multiPolygon(
    Iterable<Iterable<Iterable<Object>>> coordinates, {
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      type: Geom.multiPolygon,
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
    Object? bbox,
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

  void _coordPosition(Object coordinates) {
    if (coordinates is Position) {
      _coordPoint(
        x: coordinates.x,
        y: coordinates.y,
        z: coordinates.optZ,
        m: coordinates.optM,
      );
      return;
    } else if (coordinates is Iterable<num>) {
      final iter = coordinates.iterator;
      if (iter.moveNext()) {
        final x = iter.current;
        if (iter.moveNext()) {
          final y = iter.current;
          final optZ = iter.moveNext() ? iter.current : null;
          final optM = iter.moveNext() ? iter.current : null;
          _coordPoint(x: x, y: y, z: optZ, m: optM);
          return;
        }
      }
    }
    throw invalidCoordinates;
  }

  void _coordPoint({
    required num x,
    required num y,
    num? z,
    num? m,
  });

  @override
  void position(Object coordinates) => _coordPosition(coordinates);

  @override
  void positions1D(Iterable<Object> coordinates) {
    _coordArray(count: coordinates.length);
    for (final pos in coordinates) {
      position(pos);
    }
    _coordArrayEnd();
  }

  @override
  void positions2D(Iterable<Iterable<Object>> coordinates) {
    _coordArray(count: coordinates.length);
    for (final item in coordinates) {
      positions1D(item);
    }
    _coordArrayEnd();
  }

  @override
  void positions3D(
    Iterable<Iterable<Iterable<Object>>> coordinates,
  ) {
    _coordArray(count: coordinates.length);
    for (final item in coordinates) {
      positions2D(item);
    }
    _coordArrayEnd();
  }

  @override
  Uint8List toBytes() => Uint8List.fromList(utf8.encode(toString()));

  @override
  String toText() => _buffer.toString();

  @override
  String toString() => toText();
}

// Writer for the "default" format ---------------------------------------------

/// A geometery writer for Default text output.
class DefaultTextWriter<T extends Object> extends _BaseTextWriter<T> {
  /// A geometery writer for Default text output.
  DefaultTextWriter({
    super.buffer,
    super.decimals,
    this.ignoreMeasured = false,
  });

  /// However when [ignoreMeasured] is set to true, then M coordinates are
  /// ignored from formatting.
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
  void box(Object bbox) {
    if (_markItem()) {
      _buffer.write(',');
    }
    final notAtRoot = _notAtRoot;
    if (notAtRoot) {
      _buffer.write('[');
    }

    // Argument [bbox] should be either Box or Iterable<num> (it latter one,
    // then a Box instance is created).
    final box = Box.createFromObject<Box>(bbox, to: ProjBox.create);

    // print bounding box min and max coordinates
    _printPosition(box.min);
    _buffer.write(',');
    _printPosition(box.max);

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

  void _printPosition(Object position) {
    if (position is Position) {
      _printPoint(position.x, position.y, position.optZ, position.optM);
      return;
    } else if (position is Iterable<num>) {
      final iter = position.iterator;
      if (iter.moveNext()) {
        final x = iter.current;
        if (iter.moveNext()) {
          final y = iter.current;
          final optZ = iter.moveNext() ? iter.current : null;
          final optM = iter.moveNext() ? iter.current : null;
          _printPoint(x, y, optZ, optM);
          return;
        }
      }
    }
    throw invalidCoordinates;
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

/// A feature writer for GeoJSON text output.
class GeoJsonTextWriter<T extends Object> extends DefaultTextWriter<T>
    with FeatureContent, PropertyContent {
  /// A feature writer for GeoJSON text output.
  GeoJsonTextWriter({
    super.buffer,
    super.decimals,
    super.ignoreMeasured,
    this.ignoreForeignMembers = false,
  });

  /// When [ignoreForeignMembers] is set to true, then such JSON elements that
  /// are not described by the GeoJSON specification, are ignored. See the
  /// section 6.1 of the specifcation (RFC 7946).
  final bool ignoreForeignMembers;

  GeoJsonTextWriter<T> _subWriter() => GeoJsonTextWriter(
        buffer: _buffer,
        decimals: decimals,
        ignoreMeasured: ignoreMeasured,
      );

  @override
  bool _geometryBeforeCoordinates({
    required Geom type,
    String? name,
    Coords? coordType,
    Object? bbox,
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
      ..write(type.geoJsonName)
      ..write('"');
    if (bbox != null) {
      _buffer.write(',"bbox":[');
      _subWriter()
        .._startCoordType(coordType)
        ..box(bbox);
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
    Object? bbox,
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
        ..write(type.geoJsonName)
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

/// A geometry writer for WKT "like" text output.
class WktLikeTextWriter<T extends Object> extends _BaseTextWriter<T> {
  /// A geometry writer for WKT "like" text output.
  WktLikeTextWriter({super.buffer, super.decimals});

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
  void box(Object bbox) {
    if (_markItem()) {
      _buffer.write(',');
    }
    final notAtRoot = _notAtRoot;
    if (notAtRoot) {
      _buffer.write('(');
    }

    // Argument [bbox] should be either Box or Iterable<num> (it latter one,
    // then a Box instance is created).
    final box = Box.createFromObject<Box>(bbox, to: ProjBox.create);

    // print bounding box min and max coordinates
    _printPosition(box.min);
    _buffer.write(',');
    _printPosition(box.max);

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

  void _printPosition(Object position) {
    if (position is Position) {
      _printPoint(position.x, position.y, position.optZ, position.optM);
      return;
    } else if (position is Iterable<num>) {
      final iter = position.iterator;
      if (iter.moveNext()) {
        final x = iter.current;
        if (iter.moveNext()) {
          final y = iter.current;
          final optZ = iter.moveNext() ? iter.current : null;
          final optM = iter.moveNext() ? iter.current : null;
          _printPoint(x, y, optZ, optM);
          return;
        }
      }
    }
    throw invalidCoordinates;
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

/// A geometry writer for WKT text output.
class WktTextWriter<T extends Object> extends WktLikeTextWriter<T> {
  /// A geometry writer for WKT text output.
  WktTextWriter({super.buffer, super.decimals});

  @override
  bool _geometryBeforeCoordinates({
    required Geom type,
    String? name,
    Coords? coordType,
    Object? bbox,
  }) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _startContainer(_Container.geometry);
    _startCoordType(coordType);
    _buffer.write(type.wktName);
    final specifier = coordType?.wktSpecifier;
    if (specifier != null) {
      _buffer
        ..write(' ')
        ..write(specifier);
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
    Object? bbox,
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
      ..write(type.wktName)
      ..write(' EMPTY');
  }

  @override
  void box(Object bbox) {
    // Argument [bbox] should be either Box or Iterable<num> (it latter one,
    // then a Box instance is created).
    final box = Box.createFromObject<Box>(bbox, to: ProjBox.create);

    // WKT does not recognize bounding box, so convert to POLYGON
    final hasZ = box.is3D;
    final midZ = hasZ ? 0.5 * box.minZ! + 0.5 * box.maxZ! : null;
    final hasM = box.isMeasured;
    final midM = hasM ? 0.5 * box.minM! + 0.5 * box.maxM! : null;

    // check optional expected coordinate type
    final coordType = _coordTypes.isNotEmpty
        ? _coordTypes.last
        : Coords.select(
            is3D: hasZ,
            isMeasured: hasM,
          );
    // print polygon geometry
    if (_markItem()) {
      _buffer.write(',');
    }
    _startContainer(_Container.geometry);
    _startCoordType(coordType);
    _buffer.write(Geom.polygon.wktName);
    final specifier = coordType?.wktSpecifier;
    if (specifier != null) {
      _buffer
        ..write(' ')
        ..write(specifier);
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
