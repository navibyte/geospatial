// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/coordinates/base/box.dart';
import '/src/coordinates/crs/coord_ref_sys.dart';

/// An extent with 1 to N bounding boxes in defined coordinate reference system.
@immutable
class SpatialExtent<T extends Box> {
  final T _first;
  final Iterable<T>? _boxes;
  final CoordRefSys _coordRefSys;

  /// A spatial extent of one [bbox] (coordinate reference system in
  /// [coordRefSys]).
  const SpatialExtent(
    T bbox, {
    CoordRefSys coordRefSys = CoordRefSys.CRS84,
  })  : _first = bbox,
        _boxes = null,
        _coordRefSys = coordRefSys;

  /// A spatial extent of one [bbox].
  ///
  /// The coordinate reference system is resolved in this order:
  /// 1. [coordRefSys] if it's non-null
  /// 2. otherwise `CoordRefSys.normalized(crs)` if [crs] is non-null
  /// 3. otherwise `CoordRefSys.CRS84`
  SpatialExtent.single(
    T bbox, {
    CoordRefSys? coordRefSys,
    String? crs,
  })  : _first = bbox,
        _boxes = null,
        _coordRefSys = CoordRefSys.from(
          coordRefSys: coordRefSys,
          crs: crs,
        );

  /// A spatial extent of [boxes].
  ///
  /// The coordinate reference system is resolved in this order:
  /// 1. [coordRefSys] if it's non-null
  /// 2. otherwise `CoordRefSys.normalized(crs)` if [crs] is non-null
  /// 3. otherwise `CoordRefSys.CRS84`
  SpatialExtent.multi(
    Iterable<T> boxes, {
    CoordRefSys? coordRefSys,
    String? crs,
  })  : _boxes = _validate(boxes),
        _first = boxes.first,
        _coordRefSys = CoordRefSys.from(
          coordRefSys: coordRefSys,
          crs: crs,
        );

  static Iterable<T> _validate<T extends Box>(Iterable<T> boxes) {
    if (boxes.isEmpty) {
      throw const FormatException('At least one bounding box required.');
    }
    return boxes;
  }

  /// The first bounding box for this extent.
  T get first => _first;

  /// All bounding boxes for this extent.
  Iterable<T> get boxes => _boxes ?? [_first];

  /// The coordinate reference system for bounding boxes of this extent.
  CoordRefSys get coordRefSys => _coordRefSys;

  /// The identifier of the coordinate reference system for bounding boxes of
  /// this extent.
  ///
  /// See also [coordRefSys] that returns metadata about a coordinate reference
  /// system identified by [crs].
  @Deprecated('Use coordRefSys.id or coordRefSys.epsg instead.')
  String get crs => _coordRefSys.id;

  /// Copy this spatial extent with optional [bbox] and/or [coordRefSys]
  /// parameters changed.
  SpatialExtent<T> copyWith({T? bbox, CoordRefSys? coordRefSys}) {
    if (bbox != null) {
      return SpatialExtent(bbox, coordRefSys: coordRefSys ?? _coordRefSys);
    } else {
      if (coordRefSys != null) {
        return _boxes != null
            ? SpatialExtent.multi(_boxes!, coordRefSys: coordRefSys)
            : SpatialExtent(_first, coordRefSys: coordRefSys);
      } else {
        // ignore: avoid_returning_this
        return this;
      }
    }
  }

  @override
  String toString() {
    final buf = StringBuffer()..write(coordRefSys);
    for (final item in boxes) {
      buf
        ..write(',[')
        ..write(item)
        ..write(']');
    }
    return buf.toString();
  }

  @override
  bool operator ==(Object other) {
    if (other is SpatialExtent<T> && coordRefSys == other.coordRefSys) {
      final items1 = boxes;
      final items2 = other.boxes;
      if (items1.length == items2.length) {
        final iter2 = items2.iterator;
        for (final item1 in items1) {
          if (!(iter2.moveNext() && item1 == iter2.current)) {
            return false;
          }
        }
        return true;
      }
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(coordRefSys, Object.hashAll(boxes));
}
