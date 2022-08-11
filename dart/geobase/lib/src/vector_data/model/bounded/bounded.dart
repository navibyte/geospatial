// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/vector_data/array.dart';

/// A base interface for classes that know their bounding boxes.
abstract class Bounded {
  final BoxCoords? _bounds;

  /// A bounded object with an optional [bounds].
  const Bounded({BoxCoords? bounds}) : _bounds = bounds;

  /// The bounding box for this object, if available.
  ///
  /// Accessing this should never trigger extensive calculations. That is, if
  /// bounds is not known, then this returns the null value.
  BoxCoords? get bounds => _bounds;

/* 
  /// The bounding box for this object (calculated if not available).
  ///
  /// Please note that in some cases bounds could be pre-calculated but it's
  /// possible that accessing this property may cause extensive calculations.
  BoxCoords get requireBounds;
*/
}
