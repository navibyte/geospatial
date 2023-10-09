// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/constants/epsilon.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/projection/projection.dart';

import 'positionable.dart';

/// A positionable object with position data (direclty or within child objects)
/// and methods to resolve bounding boxes.
///
/// For example classes representing a series of positions, geometries or
/// geospatial features (with a geometry) and feature collections are considered
/// "bounded" in the context of this package.
abstract class Bounded extends Positionable {
  final Box? _bounds;

  /// A bounded object with an optional [bounds].
  const Bounded({Box? bounds}) : _bounds = bounds;

  /// Returns true if this object is considered empty (that is it do not contain
  /// any position data directly or on child objects, or a position data object
  /// contained is empty).
  bool get isEmptyByGeometry;

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

  /// Returns an object of the same subtype as this with certain data members
  /// populated.
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

  /// Returns an object of the same subtype as this with certain data members
  /// unpopulated (or cleared).
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

  /// Returns an object of the same subtype as this with all position data
  /// projected using [projection] and any other properties left intact.
  ///
  /// If [bounds] object is available on this, it's also recalculated after
  /// projecting position data. If [bounds] is null, then it's null after
  /// projecting too.
  Bounded project(Projection projection);

  /// True if this and [other] contain exactly same coordinate values (or both
  /// are empty) in the same order and with the same coordinate type.
  bool equalsCoords(covariant Bounded other);

  /// True if this and [other] equals by testing 2D coordinate values of all
  /// position data (that must be in same order in both objects) contained
  /// directly or by child objects.
  ///
  /// Returns false if this and [other] are not of the same subtype.
  ///
  /// Returns false if this or [other] contain "empty geometry"
  /// ([isEmptyByGeometry] true).
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals2D(
    covariant Bounded other, {
    double toleranceHoriz = defaultEpsilon,
  });

  /// True if this and [other] equals by testing 3D coordinate values of all
  /// position data (that must be in same order in both objects) contained
  /// directly or by child objects.
  ///
  /// Returns false if this and [other] are not of the same subtype.
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
    covariant Bounded other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  });
}
