// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

//import '/src/coordinates/base.dart';

/// A base interface for classes that know their bounding boxes.
abstract class Bounded {
  /// Default `const` constructor to allow extending this abstract class.
  const Bounded();

/* 
  /// The [bounds] for this object (could be calculated if not explicitely set).
  ///
  /// Please note that in some cases bounds could be pre-calculated but it's
  /// possible that accessing this property may cause extensive calculations.
  Box get bounds;

  /// The explicit [bounds] for this object when available.
  ///
  /// Accessing this should never trigger extensive calculations. That is, if
  /// bounds is not known, then returns the null value.
  Box? get boundsExplicit;
*/
}
