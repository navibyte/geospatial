// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/coords.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/projection/projection.dart';

/// A base interface for classes that know their bounding boxes.
abstract class Bounded {
  final Box? _bounds;

  /// A bounded object with an optional [bounds].
  const Bounded({Box? bounds}) : _bounds = bounds;

  /// Returns true if this bounded object is considered empty (that is it do
  /// not contain any geometry directly or on child objects, or geometry
  /// contained is empty).
  bool get isEmptyByGeometry;

  /// The coordinate type for this bounded object.
  /// 
  /// For bounded objects containing geometry data, the coordinate type is the
  /// type indicated by data. For example for geometries containing 2D
  /// coordinates it's `Coords.xy` or for geometries containg 3D data, it's
  /// `Coords.xyz`. 
  ///
  /// For bounded objects that are containers for other bounded objects, the
  /// returned type is such that it's valid for all items contained. For example
  /// if a collection has items with types `Coords.xy`, `Coords.xyz` and
  /// `Coords.xym`, then `Coords.xy` is returned. When all items are
  /// `Coords.xyz`, then `Coords.xyz` is returned.
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
  /// * If [traverse] > 0, then also bounding boxes of child bounded objects are
  ///   populated for child levels indicated by [traverse] (0: no childs,
  ///   1: only direct childs, 2: direct childs and childs of them, ..).
  ///
  /// See also [unpopulated].
  Bounded populated({
    int traverse = 0,
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
  /// * If [traverse] > 0, then also bounding boxes of child bounded objects are
  ///   are unpopulated for child levels indicated by [traverse] (0: no childs,
  ///   1: only direct childs, 2: direct childs and childs of them, ..).
  ///
  /// See also [populated].
  Bounded unpopulated({
    int traverse = 0,
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

  /// Returns true if this and [other] contain exactly same coordinate values
  /// (or both are empty) in the same order and with the same coordinate type.
  bool equalsCoords(Bounded other);

  /// True if this bounded object equals with [other] by testing 2D coordinates
  /// of all geometries (that must be in same order in both objects) contained
  /// directly or by child objects.
  ///
  /// Returns false if this and [other] are not of the same bounded object type.
  ///
  /// Returns false if this or [other] contain "empty geometry"
  /// ([isEmptyByGeometry] true).
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals2D(
    Bounded other, {
    double toleranceHoriz = defaultEpsilon,
  });

  /// True if this bounded object equals with [other] by testing 3D coordinates
  /// of all geometries (that must be in same order in both objects) contained
  /// directly or by child objects.
  ///
  /// Returns false if this and [other] are not of the same bounded object type.
  ///
  /// Returns false if this or [other] contain "empty geometry"
  /// ([isEmptyByGeometry] true).
  ///
  /// Returns false if this or [other] do not contain 3D coordinates.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Differences on vertical coordinate values (ie. z or elev) between
  /// this and [other] must be within [toleranceVert].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals3D(
    Bounded other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  });
}
