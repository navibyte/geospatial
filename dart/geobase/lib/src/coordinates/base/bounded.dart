// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/projection/projection.dart';

import 'box.dart';
import 'position.dart';
import 'position_scheme.dart';
import 'positionable.dart';

/// A positionable object with position data (directly or within child objects)
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
  /// Use [scheme] to set the position scheme:
  /// * `Position.scheme` for generic position data (geographic, projected or
  ///    any other), this is also the default
  /// * `Projected.scheme` for projected position data
  /// * `Geographic.scheme` for geographic position data
  ///
  /// May return null if bounds cannot be calculated (for example in the case of
  /// an empty geometry).
  Box? calculateBounds({PositionScheme scheme = Position.scheme});

  /// Returns the current [bounds] if it's populated and conforms to [scheme],
  /// or otherwise returns one calculated by [calculateBounds].
  Box? getBounds({PositionScheme scheme = Position.scheme}) {
    final b = bounds;
    return b != null && b.conforming.conformsWith(scheme)
        ? b
        : calculateBounds(scheme: scheme);
  }

  /// Returns an object of the same subtype as this with certain data members
  /// populated.
  ///
  /// If nothing is populated then `this` is returned.
  ///
  /// If [onBounds] is true (as by default):
  /// * The `bounds` in a returned bounded object is ensured to be populated
  ///   (expect when cannot be calculated, for example in the case of an empty
  ///   geometry).
  ///
  /// Use [scheme] to set the position scheme:
  /// * `Position.scheme` for generic position data (geographic, projected or
  ///    any other), this is also the default
  /// * `Projected.scheme` for projected position data
  /// * `Geographic.scheme` for geographic position data
  ///
  /// See also [unpopulated].
  Bounded populated({
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  });

  /// Returns an object of the same subtype as this with certain data members
  /// unpopulated (or cleared).
  ///
  /// If nothing is unpopulated then `this` is returned.
  ///
  /// If [onBounds] is true (as by default):
  /// * The `bounds` in a returned bounded object is ensured to be unpopulated
  ///   (expect when `bounds` is always available).
  ///
  /// See also [populated].
  Bounded unpopulated({
    bool onBounds = true,
  });

  /// Returns an object of the same subtype as this with all position data
  /// projected using [projection] and non-positional properties left intact.
  ///
  /// If [bounds] object is available on this, then it's not projected and the
  /// returned object has it set null.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // just project, the returned object has not bounds populated
  /// someBoundedObject.project(someProjection);
  ///
  /// // project and populate, the returned object has bounds populated
  /// someBoundedObject.project(someProjection).populated(onBounds: true);
  /// ```
  @override
  Bounded project(Projection projection);
}
