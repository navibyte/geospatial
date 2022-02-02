// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '/src/aspects/codes.dart';
import '/src/base/spatial.dart';
import '/src/utils/geography.dart';
import '/src/utils/num.dart';
import '/src/utils/wkt.dart';

import 'geopoint.dart';

/// An immutable geographic position with longitude and latitude.
@immutable
class GeoPoint2 extends GeoPoint with EquatableMixin {
  /// A geographic point from [lon] and [lat].
  ///
  /// Longitude is normalized to the range `[-180.0, 180.0[` using the formula
  /// `(lon + 180.0) % 360.0 - 180.0` (if outside the range) and latitude is
  /// clamped to the range `[-90.0, 90.0]`.
  const GeoPoint2({required double lon, required double lat})
      : lon =
            lon >= -180.0 && lon < 180.0 ? lon : (lon + 180.0) % 360.0 - 180.0,
        lat = lat < -90.0 ? -90.0 : (lat > 90.0 ? 90.0 : lat);

  /// A geographic position with coordinates given in order [lon], [lat].
  const GeoPoint2.lonLat(double lon, double lat) : this(lon: lon, lat: lat);

  /// A geographic position with coordinates given in order [lat], [lon].
  const GeoPoint2.latLon(double lat, double lon) : this(lat: lat, lon: lon);

  /// A geographic position at the origin (0.0, 0.0).
  const GeoPoint2.origin()
      : lon = 0.0,
        lat = 0.0;

  /// A geographic position from [coords] given in order: lon, lat.
  factory GeoPoint2.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return GeoPoint2.lonLat(
      coords.elementAt(start).toDouble(),
      coords.elementAt(start + 1).toDouble(),
    );
  }

  /// A point parsed from [text] with coordinates given in order: lon, lat.
  ///
  /// Coordinate values in [text] are separated by [delimiter]. For example
  /// `GeoPoint2.fromText('10.0;20.0', delimiter: ';')` returns the same point
  /// as `GeoPoint2.lonLat(10.0, 20.0)`.
  ///
  /// If [delimiter] is not provided, values are separated by whitespace.
  ///
  /// Throws FormatException if cannot parse.
  factory GeoPoint2.fromText(
    String text, {
    Pattern? delimiter,
  }) =>
      GeoPoint2.from(parseNumValuesFromText(text, delimiter: delimiter));

  /// A point parsed from [text] with coordinates in order: lon, lat.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory GeoPoint2.parse(String text, {ParseCoords? parser}) => parser != null
      ? GeoPoint2.from(parser.call(text))
      : parseWktPoint<GeoPoint2>(text, GeoPoint2.coordinates);

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
  static const PointFactory<GeoPoint2> coordinates =
      CastingPointFactory<GeoPoint2>(GeoPoint2.origin());

  /// A [PointFactory] creating [GeoPoint2] instances.
  @Deprecated('Use coordinates instead')
  static const PointFactory<GeoPoint2> geometry = coordinates;

  @override
  List<Object?> get props => [lon, lat];

  @override
  int get coordinateDimension => 2;

  @override
  int get spatialDimension => 2;

  @override
  bool get is3D => false;

  @override
  bool get isMeasured => false;

  @override
  Coords get typeCoords => Coords.xy;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return lon;
      case 1:
        return lat;
      default:
        return 0.0;
    }
  }

  @override
  double get x => lon;

  @override
  double get y => lat;

  @override
  final double lon;

  @override
  final double lat;

  @override
  double distanceTo(GeoPoint other) =>
      distanceHaversine(lon, lat, other.lon, other.lat);

  @override
  GeoPoint2 copyWith({num? x, num? y, num? z, num? m}) => GeoPoint2(
        lon: (x ?? lon).toDouble(),
        lat: (y ?? lat).toDouble(),
      );

  @override
  GeoPoint2 newWith({num x = 0.0, num y = 0.0, num? z, num? m}) => GeoPoint2(
        lon: x.toDouble(),
        lat: y.toDouble(),
      );

  @override
  GeoPoint2 newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(2, coords, offset: offset, length: length);
    return GeoPoint2.from(coords, offset: offset);
  }

  @override
  GeoPoint2 transform(TransformPoint transform) => transform(this);

  @override
  String toString() => '$lon,$lat';
}

/// An immutable geographic position with longitude, latitude and m (measure).
class GeoPoint2m extends GeoPoint2 {
  /// A geographic position from [lon], [lat] and [m] (m is zero by default).
  ///
  /// Longitude is normalized to the range `[-180.0, 180.0[` using the formula
  /// `(lon + 180.0) % 360.0 - 180.0` and latitude is clamped to the
  /// range `[-90.0, 90.0]`.
  const GeoPoint2m({required double lon, required double lat, this.m = 0.0})
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

  /// A point parsed from [text] with coordinates given in order: lon, lat, m.
  ///
  /// Coordinate values in [text] are separated by [delimiter]. For example
  /// `GeoPoint2m.fromText('10.0;20.0;5', delimiter: ';')` returns the same
  /// point as `GeoPoint2m.lonLatM(10.0, 20.0, 5)`.
  ///
  /// If [delimiter] is not provided, values are separated by whitespace.
  ///
  /// Throws FormatException if cannot parse.
  factory GeoPoint2m.fromText(
    String text, {
    Pattern? delimiter,
  }) =>
      GeoPoint2m.from(
        parseNumValuesFromText(text, delimiter: delimiter, minCount: 3),
      );

  /// A point parsed from [text] with coordinates in order: lon, lat, m.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 5" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory GeoPoint2m.parse(String text, {ParseCoords? parser}) => parser != null
      ? GeoPoint2m.from(parser.call(text))
      : parseWktPoint<GeoPoint2m>(text, GeoPoint2m.coordinates);

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
  static const PointFactory<GeoPoint2m> coordinates =
      CastingPointFactory<GeoPoint2m>(GeoPoint2m.origin());

  /// A [PointFactory] creating [GeoPoint2m] instances.
  @Deprecated('Use coordinates instead')
  static const PointFactory<GeoPoint2m> geometry = coordinates;

  @override
  List<Object?> get props => [lon, lat, m];

  @override
  int get coordinateDimension => 3;

  @override
  bool get isMeasured => true;

  @override
  Coords get typeCoords => Coords.xym;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return lon;
      case 1:
        return lat;
      case 2:
        return m;
      default:
        return 0.0;
    }
  }

  @override
  final double m;

  @override
  GeoPoint2m copyWith({num? x, num? y, num? z, num? m}) => GeoPoint2m(
        lon: (x ?? lon).toDouble(),
        lat: (y ?? lat).toDouble(),
        m: (m ?? this.m).toDouble(),
      );

  @override
  GeoPoint2m newWith({num x = 0.0, num y = 0.0, num? z, num? m}) => GeoPoint2m(
        lon: x.toDouble(),
        lat: y.toDouble(),
        m: m?.toDouble() ?? 0.0,
      );

  @override
  GeoPoint2m newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
    return GeoPoint2m.from(coords, offset: offset);
  }

  @override
  GeoPoint2m transform(TransformPoint transform) => transform(this);

  @override
  String toString() => '$lon,$lat,$m';
}

/// An immutable geographic position with longitude, latitude and elevation.
class GeoPoint3 extends GeoPoint2 {
  /// A geographic position from [lon], [lat] and [elev].
  const GeoPoint3({required double lon, required double lat, this.elev = 0.0})
      : super(lon: lon, lat: lat);

  /// A geographic position, coordinates given in order [lon], [lat], [elev].
  const GeoPoint3.lonLatElev(double lon, double lat, this.elev)
      : super(lon: lon, lat: lat);

  /// A geographic position, coordinates given in order [lat], [lon], [elev].
  const GeoPoint3.latLonElev(double lat, double lon, this.elev)
      : super(lon: lon, lat: lat);

  /// A geographic position at the origin (0.0, 0.0, 0.0).
  const GeoPoint3.origin()
      : elev = 0.0,
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

  /// A point parsed from [text] with coords given in order: lon, lat, elev.
  ///
  /// Coordinate values in [text] are separated by [delimiter]. For example
  /// `GeoPoint3.fromText('10.0;20.0;30.0', delimiter: ';')` returns the same
  /// point as `GeoPoint3.lonLatElev(10.0, 20.0, 30.0)`.
  ///
  /// If [delimiter] is not provided, values are separated by whitespace.
  ///
  /// Throws FormatException if cannot parse.
  factory GeoPoint3.fromText(
    String text, {
    Pattern? delimiter,
  }) =>
      GeoPoint3.from(
        parseNumValuesFromText(text, delimiter: delimiter, minCount: 3),
      );

  /// A point parsed from [text] with coordinates in order: lon, lat, elev.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 30.0" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory GeoPoint3.parse(String text, {ParseCoords? parser}) => parser != null
      ? GeoPoint3.from(parser.call(text))
      : parseWktPoint<GeoPoint3>(text, GeoPoint3.coordinates);

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
  static const PointFactory<GeoPoint3> coordinates =
      CastingPointFactory<GeoPoint3>(GeoPoint3.origin());

  /// A [PointFactory] creating [GeoPoint3] instances.
  @Deprecated('Use coordinates instead')
  static const PointFactory<GeoPoint3> geometry = coordinates;

  @override
  List<Object?> get props => [lon, lat, elev];

  @override
  int get coordinateDimension => 3;

  @override
  int get spatialDimension => 3;

  @override
  bool get is3D => true;

  @override
  Coords get typeCoords => Coords.xyz;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return lon;
      case 1:
        return lat;
      case 2:
        return elev;
      default:
        return 0.0;
    }
  }

  @override
  double get z => elev;

  @override
  final double elev;

  @override
  GeoPoint3 copyWith({num? x, num? y, num? z, num? m}) => GeoPoint3(
        lon: (x ?? lon).toDouble(),
        lat: (y ?? lat).toDouble(),
        elev: (z ?? elev).toDouble(),
      );

  @override
  GeoPoint3 newWith({num x = 0.0, num y = 0.0, num? z, num? m}) => GeoPoint3(
        lon: x.toDouble(),
        lat: y.toDouble(),
        elev: z?.toDouble() ?? 0.0,
      );

  @override
  GeoPoint3 newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
    return GeoPoint3.from(coords, offset: offset);
  }

  @override
  GeoPoint3 transform(TransformPoint transform) => transform(this);

  @override
  String toString() => '$lon,$lat,$elev';
}

/// An immutable geographic position with longitude, latitude, elev and m.
class GeoPoint3m extends GeoPoint3 {
  /// A geographic position from [lon], [lat], [elev] and [m].
  ///
  /// Longitude is normalized to the range `[-180.0, 180.0[` using the formula
  /// `(lon + 180.0) % 360.0 - 180.0` and latitude is clamped to the
  /// range `[-90.0, 90.0]`.
  const GeoPoint3m({
    required double lon,
    required double lat,
    double elev = 0.0,
    this.m = 0.0,
  }) : super(lon: lon, lat: lat, elev: elev);

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

  /// A point parsed from [text] with coords given in order: lon, lat, elev, m.
  ///
  /// Coordinate values in [text] are separated by [delimiter]. For example
  /// `GeoPoint3m.fromText('10.0;20.0;30.0;5', delimiter: ';')` returns the same
  /// point as `GeoPoint3m.lonLatElevM(10.0, 20.0, 30.0, 5)`.
  ///
  /// If [delimiter] is not provided, values are separated by whitespace.
  ///
  /// Throws FormatException if cannot parse.
  factory GeoPoint3m.fromText(
    String text, {
    Pattern? delimiter,
  }) =>
      GeoPoint3m.from(
        parseNumValuesFromText(text, delimiter: delimiter, minCount: 4),
      );

  /// A point parsed from [text] with coordinates in order: lon, lat, elev, m.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 30.0 5" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory GeoPoint3m.parse(String text, {ParseCoords? parser}) => parser != null
      ? GeoPoint3m.from(parser.call(text))
      : parseWktPoint<GeoPoint3m>(text, GeoPoint3m.coordinates);

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
  static const PointFactory<GeoPoint3m> coordinates =
      CastingPointFactory<GeoPoint3m>(GeoPoint3m.origin());

  /// A [PointFactory] creating [GeoPoint3m] instances.
  @Deprecated('Use coordinates instead')
  static const PointFactory<GeoPoint3m> geometry = coordinates;

  @override
  List<Object?> get props => [lon, lat, elev, m];

  @override
  int get coordinateDimension => 4;

  @override
  bool get isMeasured => true;

  @override
  Coords get typeCoords => Coords.xyzm;

  @override
  double operator [](int i) {
    switch (i) {
      case 0:
        return lon;
      case 1:
        return lat;
      case 2:
        return elev;
      case 3:
        return m;
      default:
        return 0.0;
    }
  }

  @override
  final double m;

  @override
  GeoPoint3m copyWith({num? x, num? y, num? z, num? m}) => GeoPoint3m(
        lon: (x ?? lon).toDouble(),
        lat: (y ?? lat).toDouble(),
        elev: (z ?? elev).toDouble(),
        m: (m ?? this.m).toDouble(),
      );

  @override
  GeoPoint3m newWith({num x = 0.0, num y = 0.0, num? z, num? m}) => GeoPoint3m(
        lon: x.toDouble(),
        lat: y.toDouble(),
        elev: z?.toDouble() ?? 0.0,
        m: m?.toDouble() ?? 0.0,
      );

  @override
  GeoPoint3m newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(4, coords, offset: offset, length: length);
    return GeoPoint3m.from(coords, offset: offset);
  }

  @override
  GeoPoint3m transform(TransformPoint transform) => transform(this);

  @override
  String toString() => '$lon,$lat,$elev,$m';
}
