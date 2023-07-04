// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math';

import '/src/coordinates/geographic/geographic.dart';

/// Returns a distance in meters between [position1] and [position2].
///
/// Given [earthRadius] is used for calculation with the approximate mean radius
/// as a default.
double distanceHaversine(
  Geographic position1,
  Geographic position2, {
  double earthRadius = 6371000.0,
}) {
  // https://en.wikipedia.org/wiki/Haversine_formula

  // coordinates
  final lon1 = position1.lon;
  final lat1 = position1.lat;
  final lon2 = position2.lon;
  final lat2 = position2.lat;

  const toRad = pi / 180.0;

  final lat1Rad = lat1 * toRad;
  final lat2Rad = lat2 * toRad;
  final dlat = (lat2 - lat1) * toRad;
  final dlon = (lon2 - lon1) * toRad;
  final a = sin(dlat / 2) * sin(dlat / 2) +
      cos(lat1Rad) * cos(lat2Rad) * sin(dlon / 2) * sin(dlon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}
