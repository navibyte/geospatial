// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/coordinates/base.dart';

/// An extent with 1 to N bounding boxes in defined coordinate reference system.
@immutable
class SpatialExtent<T extends Box> {
  final T _first;
  final Iterable<T>? _boxes;
  final String _crs;

  /// A spatial extent of one [bbox] (coordinate reference system in [crs]).
  const SpatialExtent.single(
    T bbox, {
    String crs = 'http://www.opengis.net/def/crs/OGC/1.3/CRS84',
  })  : _first = bbox,
        _boxes = null,
        _crs = crs;

  /// A spatial extent of [boxes] (coordinate reference system in [crs]).
  SpatialExtent.multi(
    Iterable<T> boxes, {
    String crs = 'http://www.opengis.net/def/crs/OGC/1.3/CRS84',
  })  : _boxes = _validate(boxes),
        _first = boxes.first,
        _crs = crs;

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
  String get crs => _crs;

  @override
  String toString() {
    final buf = StringBuffer()..write(crs);
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
    if (other is SpatialExtent<T> && crs == other.crs) {
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
  int get hashCode => Object.hash(crs, Object.hashAll(boxes));
}
