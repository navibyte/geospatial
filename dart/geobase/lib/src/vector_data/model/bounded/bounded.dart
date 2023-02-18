// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/projection.dart';
import '/src/vector_data/array.dart';

/// A base interface for classes that know their bounding boxes.
abstract class Bounded {
  final BoxCoords? _bounds;

  /// A bounded object with an optional [bounds].
  const Bounded({BoxCoords? bounds}) : _bounds = bounds;

  /// The bounding box for this object, if available.
  ///
  /// Accessing this should never trigger extensive calculations.
  BoxCoords? get bounds => _bounds;

/* 
  /// The bounding box for this object (calculated if not available).
  ///
  /// Please note that in some cases bounds could be pre-calculated but it's
  /// possible that accessing this property may cause extensive calculations.
  BoxCoords get requireBounds;
*/

  /// Returns a new bounded object with all geometries projected using
  /// [projection].
  ///
  /// The returned sub type must be the same as the type of this.
  ///
  /// Note that any available [bounds] object on this is not projected (that is
  /// the bounds for a returned object is null).
  Bounded project(Projection projection);

  // NOTE: add an optional param to "project" to ask calcuting bounds after op
}
