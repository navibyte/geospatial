// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../base.dart';
import '../utils/geography.dart';
import '../utils/wkt.dart';

/// A geographic position with longitude, latitude and optional elevation.
///
/// Longitude is available at [lon], latitude at [lat] and elevation at [elev].
///
/// Longitude (range `[-180.0, 180.0[`) and latitude (range `[-90.0, 90.0]`) are
/// represented as deegrees. The unit for [elev] is meters.
///
/// Extends [Point] class. Properties have equality (in context of this
/// library): [lon] == [x], [lat] == [y], [elev] == [z]
abstract class GeoPoint extends Point<double> {
  const GeoPoint();

  /// The longitude coordinate. Equals to [x] property.
  double get lon;

  /// The latitude coordinate. Equals to [y] property.
  double get lat;

  /// The elevation (or altitude) coordinate in meters. Equals to [z].
  ///
  /// Returns 0.0 if not available.
  double get elev => 0.0;

  /// Distance (in meters) to another geographic point.
  double distanceTo(GeoPoint other);
}

/// An immutable geographic position with longitude and latitude.
@immutable
class GeoPoint2 extends GeoPoint with EquatableMixin {
  /// A geographic point from [lon] and [lat].
  ///
  /// Longitude is normalized to the range `[-180.0, 180.0[` using the formula
  /// `(lon + 180.0) % 360.0 - 180.0` and latitude is clamped to the
  /// range `[-90.0, 90.0]`.
  const GeoPoint2({required double lon, required double lat})
      : _lon = (lon + 180.0) % 360.0 - 180.0,
        _lat = lat < -90.0 ? -90.0 : (lat > 90.0 ? 90.0 : lat);

  /// A geographic position with coordinates given in order [lon], [lat].
  const GeoPoint2.lonLat(double lon, double lat) : this(lon: lon, lat: lat);

  /// A geographic position with coordinates given in order [lat], [lon].
  const GeoPoint2.latLon(double lat, double lon) : this(lat: lat, lon: lon);

  /// A geographic position at the origin (0.0, 0.0).
  const GeoPoint2.origin()
      : _lon = 0.0,
        _lat = 0.0;

  /// A geographic position from [coords] given in order: lon, lat.
  factory GeoPoint2.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return GeoPoint2.lonLat(
      coords.elementAt(start).toDouble(),
      coords.elementAt(start + 1).toDouble(),
    );
  }

  /// A point parsed from [text] with coordinates in order: lon, lat.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory GeoPoint2.parse(String text, {ParseCoords? parser}) => parser != null
      ? GeoPoint2.from(parser.call(text))
      : parseWktPoint<GeoPoint2>(text, GeoPoint2.geometry);

  /// A point parsed from [text] with coordinates in order: lon, lat.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0" is expected.
  ///
  /// Returns null if cannot parse.
  static GeoPoint2? tryParse(String text, {ParseCoords? parser}) {
    try {
      return GeoPoint2.parse(text, parser: parser);
    } on Exception {
      return null;
    }
  }

  /// A [PointFactory] creating [GeoPoint2] instances.
  static const PointFactory<GeoPoint2> geometry =
      CastingPointFactory<GeoPoint2>(GeoPoint2.origin());

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
  bool get is3D => false;

  @override
  bool get hasM => false;

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
  double distanceTo(GeoPoint other) =>
      distanceHaversine(_lon, _lat, other.lon, other.lat);

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) => GeoPoint2(
        lon: x.toDouble(),
        lat: y.toDouble(),
      );

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(2, coords, offset: offset, length: length);
    return GeoPoint2.from(coords, offset: offset);
  }
}

/// An immutable geographic position with longitude, latitude and m (measure).
@immutable
class GeoPoint2m extends GeoPoint2 {
  /// A geographic position from [lon], [lat] and [m].
  ///
  /// Longitude is normalized to the range `[-180.0, 180.0[` using the formula
  /// `(lon + 180.0) % 360.0 - 180.0` and latitude is clamped to the
  /// range `[-90.0, 90.0]`.
  const GeoPoint2m({required double lon, required double lat, required this.m})
      : super(lon: lon, lat: lat);

  /// A geographic position with coordinates given in order [lon], [lat], [m].
  const GeoPoint2m.lonLatM(double lon, double lat, double m)
      : this(lon: lon, lat: lat, m: m);

  /// A geographic position with coordinates given in order [lat], [lon], [m].
  const GeoPoint2m.latLonM(double lat, double lon, double m)
      : this(lat: lat, lon: lon, m: m);

  /// A geographic position at the origin (0.0, 0.0, 0.0).
  const GeoPoint2m.origin()
      : m = 0.0,
        super.origin();

  /// A geographic position from [coords] given in order: lon, lat, m.
  factory GeoPoint2m.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return GeoPoint2m.lonLatM(
      coords.elementAt(start).toDouble(),
      coords.elementAt(start + 1).toDouble(),
      coords.elementAt(start + 2).toDouble(),
    );
  }

  /// A point parsed from [text] with coordinates in order: lon, lat, m.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 5" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory GeoPoint2m.parse(String text, {ParseCoords? parser}) => parser != null
      ? GeoPoint2m.from(parser.call(text))
      : parseWktPoint<GeoPoint2m>(text, GeoPoint2m.geometry);

  /// A point parsed from [text] with coordinates in order: lon, lat, m.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 5" is expected.
  ///
  /// Returns null if cannot parse.
  static GeoPoint2m? tryParse(String text, {ParseCoords? parser}) {
    try {
      return GeoPoint2m.parse(text, parser: parser);
    } on Exception {
      return null;
    }
  }

  /// A [PointFactory] creating [GeoPoint2m] instances.
  static const PointFactory<GeoPoint2m> geometry =
      CastingPointFactory<GeoPoint2m>(GeoPoint2m.origin());

  @override
  final double m;

  @override
  List<Object?> get props => [_lon, _lat, m];

  @override
  int get coordinateDimension => 3;

  @override
  bool get hasM => true;

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

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) => GeoPoint2m(
        lon: x.toDouble(),
        lat: y.toDouble(),
        m: m?.toDouble() ?? 0.0,
      );

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
    return GeoPoint2m.from(coords, offset: offset);
  }
}

/// An immutable geographic position with longitude, latitude and elevation.
class GeoPoint3 extends GeoPoint2 {
  /// A geographic position from [lon], [lat] and [elev].
  const GeoPoint3({required double lon, required double lat, double elev = 0.0})
      : _elev = elev,
        super(lon: lon, lat: lat);

  /// A geographic position, coordinates given in order [lon], [lat], [elev].
  const GeoPoint3.lonLatElev(double lon, double lat, double elev)
      : _elev = elev,
        super(lon: lon, lat: lat);

  /// A geographic position, coordinates given in order [lat], [lon], [elev].
  const GeoPoint3.latLonElev(double lat, double lon, double elev)
      : _elev = elev,
        super(lon: lon, lat: lat);

  /// A geographic position at the origin (0.0, 0.0, 0.0).
  const GeoPoint3.origin()
      : _elev = 0.0,
        super.origin();

  /// A geographic position from [coords], given in order: lon, lat, elev.
  factory GeoPoint3.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return GeoPoint3.lonLatElev(
      coords.elementAt(start).toDouble(),
      coords.elementAt(start + 1).toDouble(),
      coords.elementAt(start + 2).toDouble(),
    );
  }

  /// A point parsed from [text] with coordinates in order: lon, lat, elev.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 30.0" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory GeoPoint3.parse(String text, {ParseCoords? parser}) => parser != null
      ? GeoPoint3.from(parser.call(text))
      : parseWktPoint<GeoPoint3>(text, GeoPoint3.geometry);

  /// A point parsed from [text] with coordinates in order: lon, lat, elev.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 30.0" is expected.
  ///
  /// Returns null if cannot parse.
  static GeoPoint3? tryParse(String text, {ParseCoords? parser}) {
    try {
      return GeoPoint3.parse(text, parser: parser);
    } on Exception {
      return null;
    }
  }

  /// A [PointFactory] creating [GeoPoint3] instances.
  static const PointFactory<GeoPoint3> geometry =
      CastingPointFactory<GeoPoint3>(GeoPoint3.origin());

  final double _elev;

  @override
  List<Object?> get props => [_lon, _lat, _elev];

  @override
  int get coordinateDimension => 3;

  @override
  int get spatialDimension => 3;

  @override
  bool get is3D => true;

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

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) => GeoPoint3(
        lon: x.toDouble(),
        lat: y.toDouble(),
        elev: z?.toDouble() ?? 0.0,
      );

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
    return GeoPoint3.from(coords, offset: offset);
  }
}

/// An immutable geographic position with longitude, latitude, elev and m.
@immutable
class GeoPoint3m extends GeoPoint3 {
  /// A geographic position from [lon], [lat], [elev] and [m].
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

  /// A geographic position, coordinates in order [lon], [lat], [elev], [m].
  const GeoPoint3m.lonLatElevM(double lon, double lat, double elev, double m)
      : this(lon: lon, lat: lat, elev: elev, m: m);

  /// A geographic position, coordinates in order [lat], [lon], [elev], [m].
  const GeoPoint3m.latLonElevM(double lat, double lon, double elev, double m)
      : this(lat: lat, lon: lon, elev: elev, m: m);

  /// A geographic position at the origin (0.0, 0.0, 0.0, 0.0).
  const GeoPoint3m.origin()
      : m = 0.0,
        super.origin();

  /// A geographic position from [coords], given in order: lon, lat, elev, m.
  factory GeoPoint3m.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return GeoPoint3m.lonLatElevM(
      coords.elementAt(start).toDouble(),
      coords.elementAt(start + 1).toDouble(),
      coords.elementAt(start + 2).toDouble(),
      coords.elementAt(start + 3).toDouble(),
    );
  }

  /// A point parsed from [text] with coordinates in order: lon, lat, elev, m.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 30.0 5" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory GeoPoint3m.parse(String text, {ParseCoords? parser}) => parser != null
      ? GeoPoint3m.from(parser.call(text))
      : parseWktPoint<GeoPoint3m>(text, GeoPoint3m.geometry);

  /// A point parsed from [text] with coordinates in order: lon, lat, elev, m.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 30.0 5" is expected.
  ///
  /// Returns null if cannot parse.
  static GeoPoint3m? tryParse(String text, {ParseCoords? parser}) {
    try {
      return GeoPoint3m.parse(text, parser: parser);
    } on Exception {
      return null;
    }
  }

  /// A [PointFactory] creating [GeoPoint3m] instances.
  static const PointFactory<GeoPoint3m> geometry =
      CastingPointFactory<GeoPoint3m>(GeoPoint3m.origin());

  @override
  final double m;

  @override
  List<Object?> get props => [_lon, _lat, _elev, m];

  @override
  int get coordinateDimension => 4;

  @override
  bool get hasM => true;

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

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) => GeoPoint3m(
        lon: x.toDouble(),
        lat: y.toDouble(),
        elev: z?.toDouble() ?? 0.0,
        m: m?.toDouble() ?? 0.0,
      );

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(4, coords, offset: offset, length: length);
    return GeoPoint3m.from(coords, offset: offset);
  }
}
