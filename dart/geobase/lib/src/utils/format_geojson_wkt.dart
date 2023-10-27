// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// NOTE: this code has grown quite complex, separate geojson + wkt writers

import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '/src/common/codes/axis_order.dart';
import '/src/common/codes/coords.dart';
import '/src/common/codes/geom.dart';
import '/src/common/reference/coord_ref_sys.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_series.dart';
import '/src/utils/num.dart';
import '/src/vector/content/coordinates_content.dart';
import '/src/vector/content/feature_content.dart';
import '/src/vector/content/geometry_content.dart';
import '/src/vector/encoding/content_encoder.dart';
import '/src/vector/formats/geojson/geojson_format.dart';

import 'coord_type.dart';

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
  _BaseTextWriter({StringSink? buffer, this.decimals, this.crs})
      : _buffer = buffer ?? StringBuffer();

  final StringSink _buffer;
  final int? decimals;

  /// Optional information about coordinate reference system related to data
  /// to be written by a text writer.
  ///
  /// Text writer implementation may act (ie. swap x and y for certain crs) but
  /// they are free also to ignore this.
  ///
  /// TextWriterFormat defines this:
  /// "Use [crs] to give hints (like axis order, and whether x and y must be
  /// swapped when writing) about coordinate reference system in text output".
  final CoordRefSys? crs;

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
    Box? bounds,
  }) {
    _startCoordType(coordType);
    return true;
  }

  void _geometryAfterCoordinates() {
    _endCoordType();
  }

  @override
  void point(
    Position position, {
    String? name,
  }) {
    if (_geometryBeforeCoordinates(
      geomType: Geom.point,
      name: name,
      coordType: position.coordType,
    )) {
      _coordPosition(position);
      _geometryAfterCoordinates();
    }
  }

  @override
  void lineString(
    PositionSeries chain, {
    String? name,
    Box? bounds,
  }) {
    if (_geometryBeforeCoordinates(
      geomType: Geom.lineString,
      name: name,
      coordType: chain.coordType,
      bounds: bounds,
    )) {
      _coordPointsFromSeries(chain);
      _geometryAfterCoordinates();
    }
  }

  @override
  void polygon(
    Iterable<PositionSeries> rings, {
    String? name,
    Box? bounds,
  }) {
    if (_geometryBeforeCoordinates(
      geomType: Geom.polygon,
      name: name,
      coordType: positionSeriesArrayType(rings),
      bounds: bounds,
    )) {
      _coordArray(count: rings.length);
      for (final ring in rings) {
        _coordPointsFromSeries(ring);
      }
      _coordArrayEnd();
      _geometryAfterCoordinates();
    }
  }

  @override
  void multiPoint(
    Iterable<Position> points, {
    String? name,
    Box? bounds,
  }) {
    if (_geometryBeforeCoordinates(
      geomType: Geom.multiPoint,
      name: name,
      coordType: positionArrayType(points),
      bounds: bounds,
    )) {
      _coordArray(count: points.length);
      for (final pos in points) {
        _coordPosition(pos);
      }
      _coordArrayEnd();
      _geometryAfterCoordinates();
    }
  }

  @override
  void multiLineString(
    Iterable<PositionSeries> lineStrings, {
    String? name,
    Box? bounds,
  }) {
    if (_geometryBeforeCoordinates(
      geomType: Geom.multiLineString,
      name: name,
      coordType: positionSeriesArrayType(lineStrings),
      bounds: bounds,
    )) {
      _coordArray(count: lineStrings.length);
      for (final chain in lineStrings) {
        _coordPointsFromSeries(chain);
      }
      _coordArrayEnd();
      _geometryAfterCoordinates();
    }
  }

  @override
  void multiPolygon(
    Iterable<Iterable<PositionSeries>> polygons, {
    String? name,
    Box? bounds,
  }) {
    if (_geometryBeforeCoordinates(
      geomType: Geom.multiPolygon,
      name: name,
      coordType: positionSeriesArrayArrayType(polygons),
      bounds: bounds,
    )) {
      _coordArray(count: polygons.length);
      for (final rings in polygons) {
        _coordArray(count: rings.length);
        for (final ring in rings) {
          _coordPointsFromSeries(ring);
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
    Box? bounds,
  }) {
    if (type != null) _startCoordType(type);
    _startObjectArray(count: count);
    geometries.call(this);
    _endObjectArray();
    if (type != null) _endCoordType();
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

  void _coordPointsFromSeries(PositionSeries points) {
    _coordArray(count: points.positionCount);
    for (final pos in points.positions) {
      _coordPosition(pos);
    }
    _coordArrayEnd();
  }

  void _coordPoint({
    required double x,
    required double y,
    double? z,
    double? m,
  });

  @override
  void position(Position coordinates) {
    final type = coordinates.coordType;
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
///
/// Default text format: Swaps x and y for the output if `crs?.swapXY` is true.
///
/// This class swaps X and Y in function `_printPoint()` according to getter
/// `_crsRequiresToSwapXY`.
@internal
class DefaultTextWriter<T extends Object> extends _BaseTextWriter<T> {
  /// A geometery writer for Default text output.
  DefaultTextWriter({
    super.buffer,
    super.decimals,
    super.crs,
    GeoJsonConf? conf,
  }) : conf = conf ?? const GeoJsonConf();

  /// Configuration options for GeoJSON and GeoJSON like formats.
  final GeoJsonConf conf;

  bool get _crsRequiresToSwapXY => crs?.swapXY(logic: conf.crsLogic) ?? false;

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
  void bounds(Box bounds) {
    final type = bounds.coordType;
    _startCoordType(type);

    if (_markItem()) {
      _buffer.write(',');
    }
    final notAtRoot = _notAtRoot;
    if (notAtRoot) {
      _buffer.write('[');
    }

    // print bounding box min and max coordinates
    final min = bounds.min;
    _printPoint(min.x, min.y, min.optZ, min.optM);
    _buffer.write(',');
    final max = bounds.max;
    _printPoint(max.x, max.y, max.optZ, max.optM);

    if (notAtRoot) {
      _buffer.write(']');
    }

    _endCoordType();
  }

  @override
  void _coordPoint({
    required double x,
    required double y,
    double? z,
    double? m,
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
    double x,
    double y,
    double? z,
    double? m,
  ) {
    // whether to swap x and y
    final swapXY = _crsRequiresToSwapXY;
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
    final zValue = coordType?.is3D ?? true ? z ?? 0.0 : 0.0;
    final dec = decimals;
    if (dec != null) {
      _buffer
        ..write(toStringAsFixedWhenDecimals(swapXY ? y : x, dec))
        ..write(',')
        ..write(toStringAsFixedWhenDecimals(swapXY ? x : y, dec));
      if (printZ) {
        _buffer
          ..write(',')
          ..write(toStringAsFixedWhenDecimals(zValue, dec));
      }
      if (printM) {
        _buffer
          ..write(',')
          ..write(toStringAsFixedWhenDecimals(m ?? 0.0, dec));
      }
    } else {
      _buffer
        ..write(swapXY ? y : x)
        ..write(',')
        ..write(swapXY ? x : y);
      if (printZ) {
        _buffer
          ..write(',')
          ..write(zValue);
      }
      if (printM) {
        _buffer
          ..write(',')
          ..write(m ?? 0.0);
      }
    }
  }
}

// Writer  for the "GeoJSON" format --------------------------------------------

/// A feature writer for GeoJSON text output.
///
/// GeoJSON text format: Swaps x and y for the output if `crs?.swapXY` is true.
///
/// The super class (`DefaultTextWriter`) class swaps X and Y in function
/// `_printPoint()` according to getter `_crsRequiresToSwapXY`.
@internal
class GeoJsonTextWriter<T extends Object> extends DefaultTextWriter<T>
    with FeatureContent {
  /// A feature writer for GeoJSON text output.
  GeoJsonTextWriter({
    super.buffer,
    super.decimals,
    super.crs,
    super.conf,
  });

  GeoJsonTextWriter<T> _subWriter() => GeoJsonTextWriter(
        buffer: _buffer,
        decimals: decimals,
        crs: crs,
        conf: conf,
      );

  @override
  bool _geometryBeforeCoordinates({
    required Geom geomType,
    String? name,
    Coords? coordType,
    Box? bounds,
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
    if (bounds != null) {
      _buffer.write(',"bbox":[');
      _subWriter().bounds(bounds);
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
    Box? bounds,
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
    if (type != null) _startCoordType(type);
    _buffer.write('{"type":"GeometryCollection"');
    if (bounds != null) {
      _buffer.write(',"bbox":[');
      _subWriter().bounds(bounds);
      _buffer.write(']');
    }
    _buffer.write(',"geometries":');
    _startObjectArray(count: count);
    geometries.call(this);
    _endObjectArray();
    _buffer.write('}');
    if (type != null) _endCoordType();
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
    Box? bounds,
    Map<String, dynamic>? custom,
  }) {
    if (_atFeatureCollection) {
      return;
    }
    if (_markItem()) {
      _buffer.write(',');
    }
    _startContainer(_Container.featureCollection);
    _buffer.write('{"type":"FeatureCollection"');
    if (crs != null && conf.printNonDefaultCrs) {
      final isDefaultCrsForGeoJSON =
          crs!.isGeographic(wgs84: true, order: AxisOrder.xy);
      if (!isDefaultCrsForGeoJSON) {
        // for non-default crs print non-standard "crs" attribute
        _buffer
          ..write(',"crs":"')
          ..write(crs!.id)
          ..write('"');
      }
    }
    if (bounds != null) {
      _buffer.write(',"bbox":[');
      _subWriter().bounds(bounds);
      _buffer.write(']');
    }
    _buffer.write(',"features":');
    _startObjectArray(count: count);
    features.call(this);
    _endObjectArray();
    if (!conf.ignoreForeignMembers && custom != null) {
      _printCustom(custom);
    }
    _buffer.write('}');
    _endContainer();
  }

  @override
  void feature({
    Object? id,
    WriteGeometries? geometry,
    Map<String, dynamic>? properties,
    Box? bounds,
    Map<String, dynamic>? custom,
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
    if (bounds != null) {
      _buffer.write(',"bbox":[');
      _subWriter().bounds(bounds);
      _buffer.write(']');
    }
    if (geometry != null) {
      geometry.call(this);
    } else {
      // GeoJSON specs: there should be "geometry" element under "Feature",
      // either null or actual "Geometry" object, so printing here null then
      _buffer.write(',"geometry":null');
    }
    _printMapEntryRecursive(
      'properties',
      properties ?? const <String, Object?>{},
    );
    if (!conf.ignoreForeignMembers && custom != null) {
      _printCustom(custom);
    }
    _buffer.write('}');
    _endContainer();
  }

  void _printCustom(Map<String, dynamic> custom) {
    for (final entry in custom.entries) {
      final name = entry.key;

      // check that custom field name is not one of the GeoJSON standard names
      var isStandardField = name == 'type' ||
          name == 'bbox' ||
          name == 'features' ||
          name == 'properties' ||
          name == 'geometry' ||
          name == 'coordinates' ||
          name == 'geometries';
      if (_atFeature) {
        isStandardField |= name == 'id';
      }

      if (!isStandardField) {
        _markItem();
        _printMapEntryRecursive(name, entry.value);
      }
    }
  }

  void _printMapEntryRecursive(String name, Object? value) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _buffer
      ..write('"')
      ..write(name)
      ..write('":');
    if (value is Map<String, dynamic>) {
      _printMap(value);
    } else if (value is Iterable<dynamic>) {
      _printArray(value);
    } else {
      _printValue(value);
    }
  }

  void _printArrayItemRecursive(Object? value) {
    if (_markItem()) {
      _buffer.write(',');
    }
    if (value is Map<String, dynamic>) {
      _printMap(value);
    } else if (value is Iterable<dynamic>) {
      _printArray(value);
    } else {
      _printValue(value);
    }
  }

  void _printMap(Map<String, dynamic> map) {
    _startContainer(_Container.propertyMap);
    _buffer.write('{');
    for (final entry in map.entries) {
      _printMapEntryRecursive(entry.key, entry.value);
    }
    _buffer.write('}');
    _endContainer();
  }

  void _printArray(Iterable<dynamic> array) {
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
///
/// WKT like text format: Ignore `crs` and never swap x and y for the output.
@internal
class WktLikeTextWriter<T extends Object> extends _BaseTextWriter<T> {
  /// A geometry writer for WKT "like" text output.
  WktLikeTextWriter({super.buffer, super.decimals, super.crs});

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
  void bounds(Box bounds) {
    final type = bounds.coordType;
    _startCoordType(type);

    if (_markItem()) {
      _buffer.write(',');
    }
    final notAtRoot = _notAtRoot;
    if (notAtRoot) {
      _buffer.write('(');
    }

    // print bounding box min and max coordinates
    final min = bounds.min;
    _printPoint(min.x, min.y, min.optZ, min.optM);
    _buffer.write(',');
    final max = bounds.max;
    _printPoint(max.x, max.y, max.optZ, max.optM);

    if (notAtRoot) {
      _buffer.write(')');
    }

    _endCoordType();
  }

  @override
  void _coordPoint({
    required double x,
    required double y,
    double? z,
    double? m,
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
    double x,
    double y,
    double? z,
    double? m,
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
      zValue = z ?? 0.0;
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
      zValue = coordType?.is3D ?? true ? z ?? 0.0 : 0.0;
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
          ..write(toStringAsFixedWhenDecimals(m ?? 0.0, dec));
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
          ..write(m ?? 0.0);
      }
    }
  }
}

// Writer for the "wkt" format -------------------------------------------------

/// A geometry writer for WKT text output.
///
/// WKT text format: Ignore `crs` and never swap x and y for the output.
class WktTextWriter<T extends Object> extends WktLikeTextWriter<T> {
  /// A geometry writer for WKT text output.
  WktTextWriter({super.buffer, super.decimals, super.crs});

  @override
  bool _geometryBeforeCoordinates({
    required Geom geomType,
    String? name,
    Coords? coordType,
    Box? bounds,
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
    Box? bounds,
  }) {
    if (_markItem()) {
      _buffer.write(',');
    }
    _startContainer(_Container.geometry);
    if (type != null) _startCoordType(type);
    _buffer.write('GEOMETRYCOLLECTION');
    final specifier = type?.wktSpecifier;
    if (specifier != null) {
      _buffer
        ..write(' ')
        ..write(specifier);
    }
    _startObjectArray(count: count);
    geometries.call(this);
    _endObjectArray();
    if (type != null) _endCoordType();
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
  void bounds(Box bounds) {
    // WKT does not recognize bounding box, so convert to POLYGON
    final hasZ = bounds.is3D;
    final midZ = hasZ ? 0.5 * bounds.minZ! + 0.5 * bounds.maxZ! : null;
    final hasM = bounds.isMeasured;
    final midM = hasM ? 0.5 * bounds.minM! + 0.5 * bounds.maxM! : null;

    // coordinate type
    final coordType = bounds.coordType;

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
    _coordPoint(x: bounds.minX, y: bounds.minY, z: bounds.minZ, m: bounds.minM);
    _coordPoint(x: bounds.maxX, y: bounds.minY, z: midZ, m: midM);
    _coordPoint(x: bounds.maxX, y: bounds.maxY, z: bounds.maxZ, m: bounds.maxM);
    _coordPoint(x: bounds.minX, y: bounds.maxY, z: midZ, m: midM);
    _coordPoint(x: bounds.minX, y: bounds.minY, z: bounds.minZ, m: bounds.minM);
    _coordArrayEnd();
    _coordArrayEnd();
    _endCoordType();
    _endContainer();
  }
}
