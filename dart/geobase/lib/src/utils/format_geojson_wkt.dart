// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// todo: this code has grown quite complex, separate geojson + wkt writers

import 'dart:convert';
import 'dart:typed_data';

import 'package:geobase/src/utils/format_validation.dart';

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/coordinates/base.dart';
import '/src/coordinates/projected.dart';
import '/src/utils/num.dart';
import '/src/vector/content.dart';
import '/src/vector/encoding.dart';
import '/src/vector/formats/geojson.dart';

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
    required Geom geomType,
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
  void point(
    Iterable<double> position, {
    Coords? type,
    String? name,
  }) {
    final coordType = type ?? Coords.fromDimension(position.length);
    if (_geometryBeforeCoordinates(
      geomType: Geom.point,
      name: name,
      coordType: coordType,
    )) {
      _coordPointFromIterator(
        position.iterator,
        coordType,
      );
      _geometryAfterCoordinates();
    }
  }

  @override
  void lineString(
    Iterable<double> chain, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      geomType: Geom.lineString,
      name: name,
      coordType: type,
      bbox: bbox,
    )) {
      _coordPointsFromFlatArray(chain, type);
      _geometryAfterCoordinates();
    }
  }

  @override
  void polygon(
    Iterable<Iterable<double>> rings, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      geomType: Geom.polygon,
      name: name,
      coordType: type,
      bbox: bbox,
    )) {
      _coordArray(count: rings.length);
      for (final ring in rings) {
        _coordPointsFromFlatArray(ring, type);
      }
      _coordArrayEnd();
      _geometryAfterCoordinates();
    }
  }

  @override
  void multiPoint(
    Iterable<Iterable<double>> points, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      geomType: Geom.multiPoint,
      name: name,
      coordType: type,
      bbox: bbox,
    )) {
      _coordArray(count: points.length);
      for (final pos in points) {
        _coordPointFromIterator(pos.iterator, type);
      }
      _coordArrayEnd();
      _geometryAfterCoordinates();
    }
  }

  @override
  void multiLineString(
    Iterable<Iterable<double>> lineStrings, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      geomType: Geom.multiLineString,
      name: name,
      coordType: type,
      bbox: bbox,
    )) {
      _coordArray(count: lineStrings.length);
      for (final chain in lineStrings) {
        _coordPointsFromFlatArray(chain, type);
      }
      _coordArrayEnd();
      _geometryAfterCoordinates();
    }
  }

  @override
  void multiPolygon(
    Iterable<Iterable<Iterable<double>>> polygons, {
    required Coords type,
    String? name,
    Box? bbox,
  }) {
    if (_geometryBeforeCoordinates(
      geomType: Geom.multiPolygon,
      name: name,
      coordType: type,
      bbox: bbox,
    )) {
      _coordArray(count: polygons.length);
      for (final rings in polygons) {
        _coordArray(count: rings.length);
        for (final ring in rings) {
          _coordPointsFromFlatArray(ring, type);
        }
        _coordArrayEnd();
      }
      _coordArrayEnd();
      _geometryAfterCoordinates();
    }
  }

  @override
  void geometryCollection(
    WriteGeometries geometries, {
    Coords? type,
    int? count,
    String? name,
    Box? bbox,
  }) {
    _startCoordType(type);
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

  void _coordPosition(Position coordinates) {
    _coordPoint(
      x: coordinates.x,
      y: coordinates.y,
      z: coordinates.optZ,
      m: coordinates.optM,
    );
  }

  void _coordPointsFromFlatArray(Iterable<double> pointsFlat, Coords type) {
    final dim = type.coordinateDimension;
    final numPoints = pointsFlat.length ~/ dim;
    _coordArray(count: numPoints);
    final iter = pointsFlat.iterator;
    for (var i = 0; i < numPoints; i++) {
      _coordPointFromIterator(iter, type);
    }
    _coordArrayEnd();
  }

  void _coordPointFromIterator(Iterator<double> coords, Coords type) {
    final x = coords.moveNext() ? coords.current : throw invalidCoordinates;
    final y = coords.moveNext() ? coords.current : throw invalidCoordinates;
    final optZ = type.is3D ? (coords.moveNext() ? coords.current : 0.0) : null;
    final optM =
        type.isMeasured ? (coords.moveNext() ? coords.current : 0.0) : null;

    final outType = (_coordTypes.isNotEmpty ? _coordTypes.last : null) ?? type;
    _coordPoint(
      x: x,
      y: y,
      z: outType.is3D ? optZ : null,
      m: outType.isMeasured ? optM : null,
    );
  }

  void _coordPoint({
    required num x,
    required num y,
    num? z,
    num? m,
  });

  @override
  void position(Position coordinates) {
    final type = coordinates.type;
    _startCoordType(type);

    _coordPosition(coordinates);

    _endCoordType();
  }

  @override
  void positions(Iterable<Position> coordinates) {
    _coordArray(count: coordinates.length);
    for (final pos in coordinates) {
      _coordPosition(pos);
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
    GeoJsonConf? conf,
  }) : conf = conf ?? const GeoJsonConf();

  /// Configuration options for GeoJSON and GeoJSON like formats.
  final GeoJsonConf conf;

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
  void box(Box bbox) {
    final type = bbox.type;
    _startCoordType(type);

    if (_markItem()) {
      _buffer.write(',');
    }
    final notAtRoot = _notAtRoot;
    if (notAtRoot) {
      _buffer.write('[');
    }

    // Argument [bbox] should be either Box or Iterable<num> (it latter one,
    // then a Box instance is created).
    final box = Box.createFromObject<Box>(bbox, to: ProjBox.create, type: type);

    // print bounding box min and max coordinates
    final min = box.min;
    _printPoint(min.x, min.y, min.optZ, min.optM);
    _buffer.write(',');
    final max = box.max;
    _printPoint(max.x, max.y, max.optZ, max.optM);

    if (notAtRoot) {
      _buffer.write(']');
    }

    _endCoordType();
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
    final printM = !conf.ignoreMeasured && (coordType?.isMeasured ?? m != null);
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
    super.conf,
  });

  GeoJsonTextWriter<T> _subWriter() => GeoJsonTextWriter(
        buffer: _buffer,
        decimals: decimals,
        conf: conf,
      );

  @override
  bool _geometryBeforeCoordinates({
    required Geom geomType,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    if (conf.ignoreForeignMembers &&
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
      ..write(geomType.geoJsonName)
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
  void geometryCollection(
    WriteGeometries geometries, {
    Coords? type,
    int? count,
    String? name,
    Box? bbox,
  }) {
    if (conf.ignoreForeignMembers &&
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
    _startCoordType(type);
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
    if (conf.ignoreForeignMembers &&
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
  void featureCollection(
    WriteFeatures features, {
    int? count,
    Box? bbox,
    WriteProperties? custom,
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
    if (!conf.ignoreForeignMembers && custom != null) {
      _markItem();
      custom.call(this);
    }
    _buffer.write('}');
    _endContainer();
  }

  @override
  void feature({
    Object? id,
    WriteGeometries? geometry,
    Map<String, Object?>? properties,
    Box? bbox,
    WriteProperties? custom,
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
    if (geometry != null) {
      geometry.call(this);
    }
    _printMapEntryRecursive(
      'properties',
      properties ?? const <String, Object?>{},
    );
    if (!conf.ignoreForeignMembers && custom != null) {
      custom.call(this);
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
  void box(Box bbox) {
    final type = bbox.type;
    _startCoordType(type);

    if (_markItem()) {
      _buffer.write(',');
    }
    final notAtRoot = _notAtRoot;
    if (notAtRoot) {
      _buffer.write('(');
    }

    // Argument [bbox] should be either Box or Iterable<num> (it latter one,
    // then a Box instance is created).
    final box = Box.createFromObject<Box>(bbox, to: ProjBox.create, type: type);

    // print bounding box min and max coordinates
    final min = box.min;
    _printPoint(min.x, min.y, min.optZ, min.optM);
    _buffer.write(',');
    final max = box.max;
    _printPoint(max.x, max.y, max.optZ, max.optM);

    if (notAtRoot) {
      _buffer.write(')');
    }

    _endCoordType();
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

/// A geometry writer for WKT text output.
class WktTextWriter<T extends Object> extends WktLikeTextWriter<T> {
  /// A geometry writer for WKT text output.
  WktTextWriter({super.buffer, super.decimals});

  @override
  bool _geometryBeforeCoordinates({
    required Geom geomType,
    String? name,
    Coords? coordType,
    Box? bbox,
  }) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _startContainer(_Container.geometry);
    _startCoordType(coordType);
    _buffer.write(geomType.wktName);
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
  void geometryCollection(
    WriteGeometries geometries, {
    Coords? type,
    int? count,
    String? name,
    Box? bbox,
  }) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _startContainer(_Container.geometry);
    _startCoordType(type);
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
  void box(Box bbox) {
    // WKT does not recognize bounding box, so convert to POLYGON
    final hasZ = bbox.is3D;
    final midZ = hasZ ? 0.5 * bbox.minZ! + 0.5 * bbox.maxZ! : null;
    final hasM = bbox.isMeasured;
    final midM = hasM ? 0.5 * bbox.minM! + 0.5 * bbox.maxM! : null;

    // coordinate type
    final coordType = bbox.type;

    // print polygon geometry
    if (_markItem()) {
      _buffer.write(',');
    }
    _startContainer(_Container.geometry);
    _startCoordType(coordType);
    _buffer.write(Geom.polygon.wktName);
    final specifier = coordType.wktSpecifier;
    if (specifier != null) {
      _buffer
        ..write(' ')
        ..write(specifier);
    }
    _coordArray();
    _coordArray();
    _coordPoint(x: bbox.minX, y: bbox.minY, z: bbox.minZ, m: bbox.minM);
    _coordPoint(x: bbox.maxX, y: bbox.minY, z: midZ, m: midM);
    _coordPoint(x: bbox.maxX, y: bbox.maxY, z: bbox.maxZ, m: bbox.maxM);
    _coordPoint(x: bbox.minX, y: bbox.maxY, z: midZ, m: midM);
    _coordPoint(x: bbox.minX, y: bbox.minY, z: bbox.minZ, m: bbox.minM);
    _coordArrayEnd();
    _coordArrayEnd();
    _endCoordType();
    _endContainer();
  }
}
