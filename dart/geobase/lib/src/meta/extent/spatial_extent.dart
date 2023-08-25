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
  final CoordRefSys _crs;

  /// A spatial extent of one [bbox] with coordinate reference system specified
  /// by [crs].
  const SpatialExtent.single(
    T bbox, {
    CoordRefSys crs = CoordRefSys.CRS84,
  })  : _first = bbox,
        _boxes = null,
        _crs = crs;

  /// A spatial extent of [boxes] with coordinate reference system specified
  /// by [crs].
  SpatialExtent.multi(
    Iterable<T> boxes, {
    CoordRefSys crs = CoordRefSys.CRS84,
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
  CoordRefSys get crs => _crs;

  /// Copy this spatial extent with optional [boxes] and/or [crs] parameters
  /// changed.
  SpatialExtent<T> copyWith({Iterable<T>? boxes, CoordRefSys? crs}) {
    if (boxes != null) {
      return SpatialExtent.multi(boxes, crs: crs ?? _crs);
    } else {
      if (crs != null) {
        return _boxes != null
            ? SpatialExtent.multi(_boxes!, crs: crs)
            : SpatialExtent.single(_first, crs: crs);
      } else {
        // ignore: avoid_returning_this
        return this;
      }
    }
  }

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
