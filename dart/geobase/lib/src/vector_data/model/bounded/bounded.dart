// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/projection/projection.dart';

/// A base interface for classes that know their bounding boxes.
abstract class Bounded {
  final Box? _bounds;

  /// A bounded object with an optional [bounds].
  const Bounded({Box? bounds}) : _bounds = bounds;

  /// The coordinate type for this bounded object.
  Coords get coordType;

  /// An optional bounding box explicitely set (or otherwise directly available)
  /// for this object.
  ///
  /// Accessing this never triggers extensive calculations.
  ///
  /// To ensure bounds is populated [populated] (with `onBounds` set true) can
  /// be called returning potentially a new object containing this property with
  /// a value.
  Box? get bounds => _bounds;

  /// Calculate a bounding box for this object.
  ///
  /// This method calculates a value regardless whether [bounds] is populated or
  /// not.
  ///
  /// May return null if bounds cannot be calculated (for example in the case of
  /// an empty geometry).
  Box? calculateBounds();

  /// Returns a bounded object with a bounding box populated in [bounds] (and
  /// in any subitem bounding boxes too). Other properties are left intact.
  ///
  /// The returned subtype must be the same as the type of this.
  ///
  /// The [recalculate] parameter:
  /// * false: `bounds` for a returned object is calculated if [bounds] is null
  /// * true: `bounds` for a returned object is always recalculated
  ///
  /// When a calculated bounding box equals to the current bounds of this (or
  /// bounds cannot be calculated), it's allowed for implementations to return
  /// `this`.
  ///
  /// The `bounds` in returned bounded object may still be null, if bounds
  /// cannot be calculated (for example in the case of an empty geometry).
  @Deprecated('Use populated or unpopulated instead.')
  Bounded bounded({bool recalculate = false});

  /// Returns a bounded object of the same subtype as this with certain data
  /// members populated.
  ///
  /// If nothing is populated then `this` is returned.
  ///
  /// If [onBounds] is true (as by default):
  /// * The `bounds` in a returned bounded object is ensured to be populated
  ///   (expect when cannot be calculated, for example in the case of an empty
  ///   geometry).
  /// * If [traverse] is true, then also bounding boxes of any child bounded
  ///   objects are populated.
  /// 
  /// See also [unpopulated].
  Bounded populated({
    bool traverse = false,
    bool onBounds = true,
  });

  /// Returns a bounded object of the same subtype as this with certain data
  /// members unpopulated (or cleared).
  ///
  /// If nothing is unpopulated then `this` is returned.
  ///
  /// If [onBounds] is true (as by default):
  /// * The `bounds` in a returned bounded object is ensured to be unpopulated
  ///   (expect when `bounds` is always available, for example in the case of a
  ///    point geometry).
  /// * If [traverse] is true, then also bounding boxes of any child bounded
  ///   objects are unpopulated.
  /// 
  /// See also [populated].
  Bounded unpopulated({
    bool traverse = false,
    bool onBounds = true,
  });

  /// Returns a new bounded object with all geometries projected using
  /// [projection] and other properties left intact.
  ///
  /// The returned subtype must be the same as the type of this.
  ///
  /// If [bounds] object is available on this, it's recalculated after
  /// projecting geometries. If [bounds] is null, then it's null after
  /// projecting too.
  Bounded project(Projection projection);
}
