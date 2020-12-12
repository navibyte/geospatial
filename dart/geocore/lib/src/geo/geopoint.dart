// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../base/point.dart';
import '../utils/geography/geoutils.dart';

/// A geographic point with getters on [lon] and [lat], optionally on [elev].
///
/// The unit for [elev] is meters.
///
/// Extends Point class. Properties have equality (in context of this library):
/// [lon] == [x], [lat] == [y], [elev] == [z]
abstract class GeoPoint extends Point {
  const GeoPoint();

  /// A GeoPoint from [coords]: 2D, 3D, 2D with m or 3D with m.
  ///
  /// Throws FormatException if cannot create point.
  factory GeoPoint.from(Iterable<double> coords, {bool expectM = false}) {
    if (expectM) {
      if (coords.length >= 4) {
        return GeoPoint3m.from(coords);
      } else if (coords.length == 3) {
        return GeoPoint2m.from(coords);
      }
    } else {
      if (coords.length >= 3) {
        return GeoPoint3.from(coords);
      } else if (coords.length == 2) {
        return GeoPoint2.from(coords);
      }
    }
    throw FormatException('Not a valid point.');
  }

  /// [lon] coordinate. Equals to [x] property.
  double get lon;

  /// [lat] coordinate. Equals to [y] property.
  double get lat;

  /// [elev] coordinate (meters). Returns 0.0 if not available. Equals to [z].
  double get elev => 0.0;

  /// Distance (in meters) to another geographic point.
  double distanceTo(GeoPoint other);
}

/// An immutable geographic point with longitude and latitude.
@immutable
class GeoPoint2 extends GeoPoint with EquatableMixin {
  /// A geographic point at given [lon] and [lat].
  ///
  /// Longitude is normalized to the range `[-180.0, 180.0[` using the formula
  /// `(lon + 180.0) % 360.0 - 180.0` and latitude is clamped to the
  /// range `[-90.0, 90.0]`.
  const GeoPoint2({required double lon, required double lat})
      : _lon = (lon + 180.0) % 360.0 - 180.0,
        _lat = lat < -90.0 ? -90.0 : (lat > 90.0 ? 90.0 : lat);

  /// A geographic point with coordinates given in order [lon], [lat].
  const GeoPoint2.lonLat(double lon, double lat) : this(lon: lon, lat: lat);

  /// A geographic point with coordinates given in order [lat], [lon].
  const GeoPoint2.latLon(double lat, double lon) : this(lat: lat, lon: lon);

  /// A geographic point at the origin (0.0, 0.0).
  const GeoPoint2.origin()
      : _lon = 0.0,
        _lat = 0.0;

  /// A geographic point from [coords] given in order: lon, lat.
  factory GeoPoint2.from(Iterable<double> coords) =>
      GeoPoint2.lonLat(coords.elementAt(0), coords.elementAt(1));

  final double _lon, _lat;

  @override
  List<Object?> get props => [_lon, _lat];

  @override
  bool get isEmpty => false;

  @override
  int get coordinateDimension => 2;

  @override
  int get spatialDimension => 2;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return _lon;
      case 1:
        return _lat;
      default:
        return 0.0;
    }
  }

  @override
  double get x => _lon;

  @override
  double get y => _lat;

  @override
  double get lon => _lon;

  @override
  double get lat => _lat;

  @override
  double distanceTo(GeoPoint other) {
    return distanceHaversine(_lon, _lat, other.lon, other.lat);
  }
}

/// An immutable geographic point with longitude, latitude and m (measure).
@immutable
class GeoPoint2m extends GeoPoint2 {
  /// A geographic point at given [lon], [lat] and [m].
  ///
  /// Longitude is normalized to the range `[-180.0, 180.0[` using the formula
  /// `(lon + 180.0) % 360.0 - 180.0` and latitude is clamped to the
  /// range `[-90.0, 90.0]`.
  const GeoPoint2m({required double lon, required double lat, required this.m})
      : super(lon: lon, lat: lat);

  /// A geographic point with coordinates given in order [lon], [lat], [m].
  const GeoPoint2m.lonLatM(double lon, double lat, double m)
      : this(lon: lon, lat: lat, m: m);

  /// A geographic point with coordinates given in order [lat], [lon], [m].
  const GeoPoint2m.latLonM(double lat, double lon, double m)
      : this(lat: lat, lon: lon, m: m);

  /// A geographic point at the origin (0.0, 0.0, 0.0).
  const GeoPoint2m.origin()
      : m = 0.0,
        super.origin();

  /// A geographic point from [coords] given in order: lon, lat, m.
  factory GeoPoint2m.from(Iterable<double> coords) => GeoPoint2m.lonLatM(
      coords.elementAt(0), coords.elementAt(1), coords.elementAt(2));

  @override
  final double m;

  @override
  List<Object?> get props => [_lon, _lat, m];

  @override
  int get coordinateDimension => 3;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return _lon;
      case 1:
        return _lat;
      case 2:
        return m;
      default:
        return 0.0;
    }
  }
}

/// An immutable geographic point with longitude, latitude and elevation.
class GeoPoint3 extends GeoPoint2 {
  /// A geographic point at given [lon] and [lat] ([elev] is zero by default).
  const GeoPoint3({required double lon, required double lat, double elev = 0.0})
      : _elev = elev,
        super(lon: lon, lat: lat);

  /// A geographic point with coordinates given in order [lon], [lat], [elev].
  const GeoPoint3.lonLatElev(double lon, double lat, double elev)
      : _elev = elev,
        super(lon: lon, lat: lat);

  /// A geographic point with coordinates given in order [lat], [lon], [elev].
  const GeoPoint3.latLonElev(double lat, double lon, double elev)
      : _elev = elev,
        super(lon: lon, lat: lat);

  /// A geographic point at the origin (0.0, 0.0, 0.0).
  const GeoPoint3.origin()
      : _elev = 0.0,
        super.origin();

  /// A geographic point from [coords] given in order: lon, lat, elev.
  factory GeoPoint3.from(Iterable<double> coords) => GeoPoint3.lonLatElev(
      coords.elementAt(0), coords.elementAt(1), coords.elementAt(2));

  final double _elev;

  @override
  List<Object?> get props => [_lon, _lat, _elev];

  @override
  int get coordinateDimension => 3;

  @override
  int get spatialDimension => 3;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return _lon;
      case 1:
        return _lat;
      case 2:
        return _elev;
      default:
        return 0.0;
    }
  }

  @override
  double get z => _elev;

  @override
  double get elev => _elev;
}

/// An immutable geographic point with longitude, latitude, elev and m.
@immutable
class GeoPoint3m extends GeoPoint3 {
  /// A geographic point at given [lon], [lat], [elev] and [m].
  ///
  /// Longitude is normalized to the range `[-180.0, 180.0[` using the formula
  /// `(lon + 180.0) % 360.0 - 180.0` and latitude is clamped to the
  /// range `[-90.0, 90.0]`.
  const GeoPoint3m(
      {required double lon,
      required double lat,
      required double elev,
      required this.m})
      : super(lon: lon, lat: lat, elev: elev);

  /// A geographic point with coordinates in order [lon], [lat], [elev], [m].
  const GeoPoint3m.lonLatElevM(double lon, double lat, double elev, double m)
      : this(lon: lon, lat: lat, elev: elev, m: m);

  /// A geographic point with coordinates in order [lat], [lon], [elev], [m].
  const GeoPoint3m.latLonElevM(double lat, double lon, double elev, double m)
      : this(lat: lat, lon: lon, elev: elev, m: m);

  /// A geographic point at the origin (0.0, 0.0, 0.0, 0.0).
  const GeoPoint3m.origin()
      : m = 0.0,
        super.origin();

  /// A geographic point from [coords] given in order: lon, lat, elev, m.
  factory GeoPoint3m.from(Iterable<double> coords) => GeoPoint3m.lonLatElevM(
      coords.elementAt(0),
      coords.elementAt(1),
      coords.elementAt(2),
      coords.elementAt(3));

  @override
  final double m;

  @override
  List<Object?> get props => [_lon, _lat, _elev, m];

  @override
  int get coordinateDimension => 4;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return _lon;
      case 1:
        return _lat;
      case 2:
        return elev;
      case 3:
        return m;
      default:
        return 0.0;
    }
  }
}
