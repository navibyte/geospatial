// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'geographic.dart';

// NOTE: This specifies an object with position and bearing. In future an
//       extended class (like GeographicOrientation) might provide also tilt and
//       roll angles, or map specific properties (tilt, zoom) like in google map
//       CameraPosition. This shall be analyzed later...

/// {@template geobase.coordinates.geographic_bearing.about}
///
/// A direction (bearing) in degrees clockwise from north at a specific
/// geographic position (origin).
///
/// {@endtemplate}
@immutable
class GeographicBearing {
  /// A geographic position as a origin point for a direction specified by
  /// [bearing].
  final Geographic origin;

  /// A direction in degrees clockwise from north (0°..360°) as observed from
  /// [origin].
  final double bearing;

  /// {@macro geobase.coordinates.geographic_bearing.about}
  const GeographicBearing({required this.origin, required this.bearing});

  @override
  String toString() {
    return '$origin;$bearing';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeographicBearing &&
          origin == other.origin &&
          bearing == other.bearing);

  @override
  int get hashCode => Object.hash(origin, bearing);
}
