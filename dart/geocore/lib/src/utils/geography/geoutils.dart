// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'dart:math';

/// Distance returns a distance between two points. Result is meters.
double distanceHaversine(double lon1, double lat1, double lon2, double lat2) {
  // using "haversine" formula
  // see: http://mathforum.org/library/drmath/view/51879.html

  const earthRadius = 6371000.0;
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
