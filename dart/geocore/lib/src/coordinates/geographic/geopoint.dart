// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/geobase.dart';

import '/src/base/spatial.dart';

/// A geographic position with longitude, latitude and optional elevation.
///
/// Longitude is available at [lon], latitude at [lat] and elevation at [elev].
///
/// Longitude (range `[-180.0, 180.0[`) and latitude (range `[-90.0, 90.0]`) are
/// represented as deegrees. The unit for [elev] is meters.
///
/// Extends [Point] class. Properties have equality (in context of this
/// library): [lon] == [x], [lat] == [y], [elev] == [z]
abstract class GeoPoint extends Point<double> implements GeoPosition {
  /// Default `const` constructor to allow extending this abstract class.
  const GeoPoint();

  @override
  double get elev => 0.0;

  @override
  double? get optElev => null;

  /// Distance (in meters) to another geographic point.
  double distanceTo(GeoPoint other);

  /// Copies this point with the compatible type and sets given coordinates.
  ///
  /// Optional [x], [y], [z] and [m] values, when given, override values of
  /// this point object. If the type of this point does not have a certain
  /// value, then it's ignored.
  ///
  /// Properties have equality (in context of this library): [lon] == [x],
  /// [lat] == [y], [elev] == [z]
  @override
  GeoPoint copyWith({num? x, num? y, num? z, num? m});

  @override
  GeoPoint newWith({num x = 0.0, num y = 0.0, num? z, num? m});

  @override
  GeoPoint newFrom(Iterable<num> coords, {int? offset, int? length});

  /// Returns a new point transformed from this point using [transform].
  ///
  /// The transformed point object must be of the type with same coordinate
  /// value members as this object has.
  @override
  GeoPoint transform(TransformPosition transform);

  @override
  bool get isGeographic => true;

  @override
  bool operator ==(Object other) =>
      other is GeoPoint && GeoPosition.testEquals(this, other);

  @override
  int get hashCode => GeoPosition.hash(this);

  @override
  bool equals2D(BasePosition other, {num? toleranceHoriz}) =>
      other is GeoPosition &&
      GeoPosition.testEquals2D(
        this,
        other,
        toleranceHoriz: toleranceHoriz?.toDouble(),
      );

  @override
  bool equals3D(
    BasePosition other, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) =>
      other is GeoPosition &&
      GeoPosition.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz?.toDouble(),
        toleranceVert: toleranceVert?.toDouble(),
      );
}
