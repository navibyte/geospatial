// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

import '../base.dart';

import 'geopoint.dart';

/// An immutable geographic bounds with min and max points for limits.
///
/// Geographic bounds can be represented as Bounds<GeoPoint> or as GeoBounds.
/// This is a convenience class with helper factory constructors.
class GeoBounds extends BoundsBase<GeoPoint> with EquatableMixin {
  /// Create geographic bounds with required [min] and [max] points.
  ///
  /// [min] and [max] objects set on the bounds may or may not to be immutable.
  const GeoBounds.of({
    required GeoPoint min,
    required GeoPoint max,
  }) : super(min: min, max: max);

  /// World bounds (longitude: -180.0 to 180.0, latitude: -90.0 to 90.0).
  const GeoBounds.world()
      : this.of(
            min: const GeoPoint2.lonLat(-180.0, -90.0),
            max: const GeoPoint2.lonLat(180.0, 90.0));

  /// With minimum and maximum pairs of longitude and latitude (+optional elev).
  GeoBounds.bbox(
      {required double minLon,
      required double minLat,
      double? minElev,
      required double maxLon,
      required double maxLat,
      double? maxElev})
      : this.of(
            min: minElev != null
                ? GeoPoint3.lonLatElev(minLon, minLat, minElev)
                : GeoPoint2.lonLat(minLon, minLat),
            max: maxElev != null
                ? GeoPoint3.lonLatElev(maxLon, maxLat, maxElev)
                : GeoPoint2.lonLat(maxLon, maxLat));

  /// With minimum and maximum pairs of longitude and latitude.
  GeoBounds.bboxLonLat(
      double minLon, double minLat, double maxLon, double maxLat)
      : this.of(
            min: GeoPoint2.lonLat(minLon, minLat),
            max: GeoPoint2.lonLat(maxLon, maxLat));

  /// With minimum and maximum sets of longitude, latitude and elevation.
  GeoBounds.bboxLonLatElev(double minLon, double minLat, double minElev,
      double maxLon, double maxLat, double maxElev)
      : this.of(
            min: GeoPoint3.lonLatElev(minLon, minLat, minElev),
            max: GeoPoint3.lonLatElev(maxLon, maxLat, maxElev));

  /// With minimum and maximum pairs of latitude and longitude.
  GeoBounds.bboxLatLon(
      double minLat, double minLon, double maxLat, double maxLon)
      : this.of(
            min: GeoPoint2.latLon(minLat, minLon),
            max: GeoPoint2.latLon(maxLat, maxLon));

  /// With [coords] containing min and max sets of lon, lat and optional elev.
  ///
  /// There should be either 4 or 6 items on [coords].
  factory GeoBounds.from(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(4, coords, offset: offset, length: length);
    final start = offset ?? 0;
    final len = length ?? coords.length;
    return len >= 6
        ? GeoBounds.bboxLonLatElev(
            coords.elementAt(start + 0).toDouble(),
            coords.elementAt(start + 1).toDouble(),
            coords.elementAt(start + 2).toDouble(),
            coords.elementAt(start + 3).toDouble(),
            coords.elementAt(start + 4).toDouble(),
            coords.elementAt(start + 5).toDouble(),
          )
        : GeoBounds.bboxLonLat(
            coords.elementAt(start + 0).toDouble(),
            coords.elementAt(start + 1).toDouble(),
            coords.elementAt(start + 2).toDouble(),
            coords.elementAt(start + 3).toDouble(),
          );
  }

  @override
  Bounds newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(4, coords, offset: offset, length: length);
    final start = offset ?? 0;
    final len = length ?? coords.length;
    final pointLen = len ~/ 2;
    return GeoBounds.of(
        min: min.newFrom(coords, offset: start, length: pointLen) as GeoPoint,
        max: max.newFrom(coords, offset: start + pointLen, length: pointLen)
            as GeoPoint);
  }
}
