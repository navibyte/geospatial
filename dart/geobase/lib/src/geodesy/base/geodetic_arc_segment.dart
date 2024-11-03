// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/geographic/geographic.dart';
import '/src/coordinates/geographic/geographic_bearing.dart';

/// {@template geobase.geodesy.geodetic_arc_segment.about}
///
/// A geodetic (geographic) arc segment between the [origin] position and the
/// [destination] position along a geodesic.
///
/// This data structure contains also an initial [bearing] (observed on the
/// origin position), [distance] in meters between the two positions and a
/// [finalBearing] (observed on the destination position). These values should
/// be pre-calculated before constructing an instance either using spherical or
/// ellipsoidal Earth models.
///
/// For a spherical Earth model, a geodesic is a segment of a great circle. For
/// an ellipsoidal Earth model, a geodesic is a bit more complex, but still it's
/// defined to be the shortest path which can be drawn between its two points on
/// the surface of the Earth (represented by an ellipsoid).
///
/// Read more about [geodesics](https://en.wikipedia.org/wiki/Geodesic) in
/// general and related to
/// [ellipsoids](https://en.wikipedia.org/wiki/Geodesics_on_an_ellipsoid) on
/// Wikipedia.
///
/// {@endtemplate}
class GeodeticArcSegment extends GeographicBearing {
  /// The distance in meters between the [origin] position and the [destination]
  /// position.
  final double distance;

  /// A direction in degrees clockwise from north (0°..360°) as observed on a
  /// geodetic arg segment when reaching the [destination] position.
  final double finalBearing;

  /// A geographic position as a destination point on a geodetic arc segment
  /// between [origin] and [destination] positions.
  final Geographic destination;

  /// {@macro geobase.geodesy.geodetic_arc_segment.about}
  const GeodeticArcSegment({
    required super.origin,
    required super.bearing,
    required this.distance,
    required this.finalBearing,
    required this.destination,
  });

  @override
  String toString() {
    return '$origin;$bearing;$distance;$finalBearing;$destination';
  }

  @override
  bool operator ==(Object other) =>
      other is GeodeticArcSegment &&
      origin == other.origin &&
      bearing == other.bearing &&
      distance == other.distance &&
      finalBearing == other.finalBearing &&
      destination == other.destination;

  @override
  int get hashCode => Object.hash(
        origin,
        bearing,
        distance,
        finalBearing,
        destination,
      );
}
