// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// Cartesian vector (or point) data structures:
// * Point2 with x and y as num values
// * Point2m with x, y and m as num, values
// * Point3 with x, y and z as num values
// * Point3m with x, y, z and m as num values
// * Point2i with x and y as int values
// * Point3i with x, y and z as int values

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '/src/aspects/codes.dart';
import '/src/base/spatial.dart';

import '/src/utils/num.dart';
import '/src/utils/wkt.dart';

import 'cartesian_point.dart';

/// An immutable point with X and Y as num values.
@immutable
class Point2 extends CartesianPoint<num> with EquatableMixin {
  /// A point at given [x] and [y].
  const Point2({required this.x, required this.y});

  /// A point with coordinates given in order [x], [y].
  const Point2.xy(this.x, this.y);

  /// A point at the origin (0.0, 0.0).
  const Point2.origin()
      : x = 0.0,
        y = 0.0;

  /// A point from [coords] given in order: x, y.
  factory Point2.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return Point2.xy(
      coords.elementAt(start),
      coords.elementAt(start + 1),
    );
  }

  /// A point parsed from [text] with coordinates given in order: x, y.
  ///
  /// Coordinate values in [text] are separated by [delimiter]. For example
  /// `Point2.fromText('10.0;20.0', delimiter: ';')` returns the same point as
  /// `Point2.xy(10.0, 20.0)`.
  ///
  /// If [delimiter] is not provided, values are separated by whitespace.
  ///
  /// Throws FormatException if cannot parse.
  factory Point2.fromText(
    String text, {
    Pattern? delimiter,
  }) =>
      Point2.from(parseNumValuesFromText(text, delimiter: delimiter));

  /// A point parsed from [text] with coordinates in order: x, y.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory Point2.parse(String text, {ParseCoords? parser}) => parser != null
      ? Point2.from(parser.call(text))
      : parseWktPoint<Point2>(text, Point2.coordinates);

  /// A point parsed from [text] with coordinates in order: x, y.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0" is expected.
  ///
  /// Returns null if cannot parse.
  static Point2? tryParse(String text, {ParseCoords? parser}) {
    try {
      return Point2.parse(text, parser: parser);
    } on Exception {
      return null;
    }
  }

  /// A [PointFactory] creating [Point2] instances.
  static const PointFactory<Point2> coordinates =
      CastingPointFactory<Point2>(Point2.origin());

  /// A [PointFactory] creating [Point2] instances.
  ///
  @Deprecated('Use coordinates instead')
  static const PointFactory<Point2> geometry = coordinates;

  @override
  List<Object?> get props => [x, y];

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
  num operator [](int i) {
    switch (i) {
      case 0:
        return x;
      case 1:
        return y;
      default:
        return 0.0;
    }
  }

  @override
  final num x;

  @override
  final num y;

  @override
  Point2 newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      Point2(x: x, y: y);

  @override
  Point2 newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(2, coords, offset: offset, length: length);
    return Point2.from(coords, offset: offset);
  }

  @override
  Point2 copyWith({num? x, num? y, num? z, num? m}) => Point2(
        x: x ?? this.x,
        y: y ?? this.y,
      );

  @override
  Point2 transform(TransformPoint transform) => transform(this);

  @override
  String toString() => '$x,$y';
}

/// An immutable point with X, Y and M as num values.
class Point2m extends Point2 {
  /// A point at given [x], [y] and [m] (m is zero by default).
  const Point2m({required num x, required num y, this.m = 0.0})
      : super(x: x, y: y);

  /// A point with coordinates given in order [x], [y], [m].
  const Point2m.xym(num x, num y, this.m) : super(x: x, y: y);

  /// A point at the origin (0.0, 0.0, 0.0).
  const Point2m.origin()
      : m = 0.0,
        super.origin();

  /// A point from [coords] given in order: x, y, m.
  factory Point2m.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return Point2m.xym(
      coords.elementAt(start),
      coords.elementAt(start + 1),
      coords.elementAt(start + 2),
    );
  }

  /// A point parsed from [text] with coordinates given in order: x, y, m.
  ///
  /// Coordinate values in [text] are separated by [delimiter]. For example
  /// `Point2m.fromText('10.0;20.0;5', delimiter: ';')` returns the same point
  /// as `Point2m.xym(10.0, 20.0, 5)`.
  ///
  /// If [delimiter] is not provided, values are separated by whitespace.
  ///
  /// Throws FormatException if cannot parse.
  factory Point2m.fromText(
    String text, {
    Pattern? delimiter,
  }) =>
      Point2m.from(
        parseNumValuesFromText(text, delimiter: delimiter, minCount: 3),
      );

  /// A point parsed from [text] with coordinates in order: x, y, m.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 5" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory Point2m.parse(String text, {ParseCoords? parser}) => parser != null
      ? Point2m.from(parser.call(text))
      : parseWktPoint<Point2m>(text, Point2m.coordinates);

  /// A point parsed from [text] with coordinates in order: x, y, m.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 5" is expected.
  ///
  /// Returns null if cannot parse.
  static Point2m? tryParse(String text, {ParseCoords? parser}) {
    try {
      return Point2m.parse(text, parser: parser);
    } on Exception {
      return null;
    }
  }

  /// A [PointFactory] creating [Point2m] instances.
  static const PointFactory<Point2m> coordinates =
      CastingPointFactory<Point2m>(Point2m.origin());

  /// A [PointFactory] creating [Point2m] instances.
  @Deprecated('Use coordinates instead')
  static const PointFactory<Point2m> geometry = coordinates;

  @override
  List<Object?> get props => [x, y, m];

  @override
  int get coordinateDimension => 3;

  @override
  bool get isMeasured => true;

  @override
  Coords get typeCoords => Coords.xym;

  @override
  num operator [](int i) {
    switch (i) {
      case 0:
        return x;
      case 1:
        return y;
      case 2:
        return m;
      default:
        return 0.0;
    }
  }

  @override
  final num m;

  @override
  num? get optM => m;

  @override
  Point2m copyWith({num? x, num? y, num? z, num? m}) => Point2m(
        x: x ?? this.x,
        y: y ?? this.y,
        m: m ?? this.m,
      );

  @override
  Point2m newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      Point2m(x: x, y: y, m: m ?? 0.0);

  @override
  Point2m newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
    return Point2m.from(coords, offset: offset);
  }

  @override
  Point2m transform(TransformPoint transform) => transform(this);

  @override
  String toString() => '$x,$y,$m';
}

/// An immutable point with X, Y and Z as num values.
class Point3 extends Point2 {
  /// A point at given [x], [y] and [z] (z is zero by default).
  const Point3({required num x, required num y, this.z = 0.0})
      : super(x: x, y: y);

  /// A point with coordinates given in order [x], [y], [z].
  const Point3.xyz(num x, num y, this.z) : super(x: x, y: y);

  /// A point at the origin (0.0, 0.0, 0.0).
  const Point3.origin()
      : z = 0.0,
        super.origin();

  /// A point from [coords] given in order: x, y, m.
  factory Point3.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return Point3.xyz(
      coords.elementAt(start),
      coords.elementAt(start + 1),
      coords.elementAt(start + 2),
    );
  }

  /// A point parsed from [text] with coordinates given in order: x, y, z.
  ///
  /// Coordinate values in [text] are separated by [delimiter]. For example
  /// `Point3.fromText('10.0;20.0;30.0', delimiter: ';')` returns the same point
  /// as `Point3.xyz(10.0, 20.0, 30.0)`.
  ///
  /// If [delimiter] is not provided, values are separated by whitespace.
  ///
  /// Throws FormatException if cannot parse.
  factory Point3.fromText(
    String text, {
    Pattern? delimiter,
  }) =>
      Point3.from(
        parseNumValuesFromText(text, delimiter: delimiter, minCount: 3),
      );

  /// A point parsed from [text] with coordinates in order: x, y, z.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 30.0" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory Point3.parse(String text, {ParseCoords? parser}) => parser != null
      ? Point3.from(parser.call(text))
      : parseWktPoint<Point3>(text, Point3.coordinates);

  /// A point parsed from [text] with coordinates in order: x, y, z.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 30.0" is expected.
  ///
  /// Returns null if cannot parse.
  static Point3? tryParse(String text, {ParseCoords? parser}) {
    try {
      return Point3.parse(text, parser: parser);
    } on Exception {
      return null;
    }
  }

  /// A [PointFactory] creating [Point3] instances.
  static const PointFactory<Point3> coordinates =
      CastingPointFactory<Point3>(Point3.origin());

  /// A [PointFactory] creating [Point3] instances.
  @Deprecated('Use coordinates instead')
  static const PointFactory<Point3> geometry = coordinates;

  @override
  List<Object?> get props => [x, y, z];

  @override
  int get coordinateDimension => 3;

  @override
  int get spatialDimension => 3;

  @override
  bool get is3D => true;

  @override
  Coords get typeCoords => Coords.xyz;

  @override
  num operator [](int i) {
    switch (i) {
      case 0:
        return x;
      case 1:
        return y;
      case 2:
        return z;
      default:
        return 0.0;
    }
  }

  @override
  final num z;

  @override
  num? get optZ => z;

  @override
  Point3 copyWith({num? x, num? y, num? z, num? m}) => Point3(
        x: x ?? this.x,
        y: y ?? this.y,
        z: z ?? this.z,
      );

  @override
  Point3 newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      Point3(x: x, y: y, z: z ?? 0.0);

  @override
  Point3 newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
    return Point3.from(coords, offset: offset);
  }

  @override
  Point3 transform(TransformPoint transform) => transform(this);

  @override
  String toString() => '$x,$y,$z';
}

/// An immutable point with X, Y, Z and M as num values.
class Point3m extends Point3 {
  /// A point at given [x], [y], [z] and [m] (z and m are zero by default).
  const Point3m({required num x, required num y, num z = 0.0, this.m = 0.0})
      : super(x: x, y: y, z: z);

  /// A point with coordinates given in order [x], [y], [z], [m].
  const Point3m.xyzm(num x, num y, num z, this.m) : super(x: x, y: y, z: z);

  /// A point at the origin (0.0, 0.0, 0.0, 0.0).
  const Point3m.origin()
      : m = 0.0,
        super.origin();

  /// A point from [coords] given in order: x, y, z, m.
  factory Point3m.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return Point3m.xyzm(
      coords.elementAt(start),
      coords.elementAt(start + 1),
      coords.elementAt(start + 2),
      coords.elementAt(start + 3),
    );
  }

  /// A point parsed from [text] with coordinates given in order: x, y, z, m.
  ///
  /// Coordinate values in [text] are separated by [delimiter]. For example
  /// `Point3m.fromText('10.0;20.0;30.0;5', delimiter: ';')` returns the same
  /// point as `Point3m.xyzm(10.0, 20.0, 30.0, 5)`.
  ///
  /// If [delimiter] is not provided, values are separated by whitespace.
  ///
  /// Throws FormatException if cannot parse.
  factory Point3m.fromText(
    String text, {
    Pattern? delimiter,
  }) =>
      Point3m.from(
        parseNumValuesFromText(text, delimiter: delimiter, minCount: 4),
      );

  /// A point parsed from [text] with coordinates in order: x, y, z, m.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 30.0 5" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory Point3m.parse(String text, {ParseCoords? parser}) => parser != null
      ? Point3m.from(parser.call(text))
      : parseWktPoint<Point3m>(text, Point3m.coordinates);

  /// A point parsed from [text] with coordinates in order: x, y, z, m.
  ///
  /// If [parser] is null, then WKT [text] like "10.0 20.0 30.0 5" is expected.
  ///
  /// Returns null if cannot parse.
  static Point3m? tryParse(String text, {ParseCoords? parser}) {
    try {
      return Point3m.parse(text, parser: parser);
    } on Exception {
      return null;
    }
  }

  /// A [PointFactory] creating [Point3m] instances.
  static const PointFactory<Point3m> coordinates =
      CastingPointFactory<Point3m>(Point3m.origin());

  /// A [PointFactory] creating [Point3m] instances.
  @Deprecated('Use coordinates instead')
  static const PointFactory<Point3m> geometry = coordinates;

  @override
  List<Object?> get props => [x, y, z, m];

  @override
  int get coordinateDimension => 4;

  @override
  bool get isMeasured => true;

  @override
  Coords get typeCoords => Coords.xyzm;

  @override
  num operator [](int i) {
    switch (i) {
      case 0:
        return x;
      case 1:
        return y;
      case 2:
        return z;
      case 3:
        return m;
      default:
        return 0.0;
    }
  }

  @override
  final num m;

  @override
  num? get optM => m;

  @override
  Point3m copyWith({num? x, num? y, num? z, num? m}) => Point3m(
        x: x ?? this.x,
        y: y ?? this.y,
        z: z ?? this.z,
        m: m ?? this.m,
      );

  @override
  Point3m newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      Point3m(x: x, y: y, z: z ?? 0.0, m: m ?? 0.0);

  @override
  Point3m newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(4, coords, offset: offset, length: length);
    return Point3m.from(coords, offset: offset);
  }

  @override
  Point3m transform(TransformPoint transform) => transform(this);

  @override
  String toString() => '$x,$y,$z,$m';
}

/// An immutable point with X and Y as integer values.
@immutable
class Point2i extends CartesianPoint<int> with EquatableMixin {
  /// A point at given [x] and [y].
  const Point2i({required this.x, required this.y});

  /// A point with coordinates given in order [x], [y].
  const Point2i.xy(this.x, this.y);

  /// A point at the origin (0, 0).
  const Point2i.origin()
      : x = 0,
        y = 0;

  /// A point from [coords] given in order: x, y.
  factory Point2i.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return Point2i.xy(
      coords.elementAt(start).round(),
      coords.elementAt(start + 1).round(),
    );
  }

  /// A point parsed from [text] with coordinates given in order: x, y.
  ///
  /// Coordinate values in [text] are separated by [delimiter]. For example
  /// `Point2i.fromText('10;20', delimiter: ';')` returns the same point as
  /// `Point2i.xy(10, 20)`.
  ///
  /// If [delimiter] is not provided, values are separated by whitespace.
  ///
  /// Throws FormatException if cannot parse.
  factory Point2i.fromText(
    String text, {
    Pattern? delimiter,
  }) =>
      Point2i.from(parseIntValuesFromText(text, delimiter: delimiter));

  /// A point parsed from [text] with coordinates in order: x, y.
  ///
  /// If [parser] is null, then WKT [text] like "10 20" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory Point2i.parse(String text, {ParseCoordsInt? parser}) => parser != null
      ? Point2i.from(parser.call(text))
      : parseWktPoint<Point2i>(text, Point2i.coordinates);

  /// A point parsed from [text] with coordinates in order: x, y.
  ///
  /// If [parser] is null, then WKT [text] like "10 20" is expected.
  ///
  /// Returns null if cannot parse.
  static Point2i? tryParse(String text, {ParseCoordsInt? parser}) {
    try {
      return Point2i.parse(text, parser: parser);
    } on Exception {
      return null;
    }
  }

  /// A [PointFactory] creating [Point2i] instances.
  static const PointFactory<Point2i> coordinates =
      CastingPointFactory<Point2i>(Point2i.origin());

  /// A [PointFactory] creating [Point2i] instances.
  @Deprecated('Use coordinates instead')
  static const PointFactory<Point2i> geometry = coordinates;

  @override
  List<Object?> get props => [x, y];

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
  int operator [](int i) {
    switch (i) {
      case 0:
        return x;
      case 1:
        return y;
      default:
        return 0;
    }
  }

  @override
  final int x;

  @override
  final int y;

  @override
  int get z => 0;

  @override
  int get m => 0;

  @override
  int? get optZ => null;

  @override
  int? get optM => null;

  @override
  Point2i copyWith({num? x, num? y, num? z, num? m}) => Point2i(
        x: x?.round() ?? this.x,
        y: y?.round() ?? this.y,
      );

  @override
  Point2i newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      Point2i(x: x.round(), y: y.round());

  @override
  Point2i newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(2, coords, offset: offset, length: length);
    return Point2i.from(coords, offset: offset);
  }

  @override
  Point2i transform(TransformPoint transform) => transform(this);

  @override
  String toString() => '$x,$y';
}

/// An immutable point with X, Y and Z as integer values.
class Point3i extends Point2i {
  /// A point at given [x], [y] and [z] (z is zero by default).
  const Point3i({required int x, required int y, this.z = 0})
      : super(x: x, y: y);

  /// A point with coordinates given in order: x, y, z.
  const Point3i.xyz(int x, int y, this.z) : super(x: x, y: y);

  /// A point at the origin (0, 0, 0).
  const Point3i.origin()
      : z = 0,
        super.origin();

  /// A point from [coords] given in order [x], [y], [z].
  factory Point3i.from(Iterable<num> coords, {int? offset}) {
    final start = offset ?? 0;
    return Point3i.xyz(
      coords.elementAt(start).round(),
      coords.elementAt(start + 1).round(),
      coords.elementAt(start + 2).round(),
    );
  }

  /// A point parsed from [text] with coordinates given in order: x, y, z.
  ///
  /// Coordinate values in [text] are separated by [delimiter]. For example
  /// `Point3i.fromText('10;20;30', delimiter: ';')` returns the same point as
  /// `Point3i.xyz(10, 20, 30)`.
  ///
  /// If [delimiter] is not provided, values are separated by whitespace.
  ///
  /// Throws FormatException if cannot parse.
  factory Point3i.fromText(
    String text, {
    Pattern? delimiter,
  }) =>
      Point3i.from(
        parseIntValuesFromText(text, delimiter: delimiter, minCount: 3),
      );

  /// A point parsed from [text] with coordinates in order: x, y, z.
  ///
  /// If [parser] is null, then WKT [text] like "10 20 30" is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory Point3i.parse(String text, {ParseCoordsInt? parser}) => parser != null
      ? Point3i.from(parser.call(text))
      : parseWktPoint<Point3i>(text, Point3i.coordinates);

  /// A point parsed from [text] with coordinates in order: x, y, z.
  ///
  /// If [parser] is null, then WKT [text] like "10 20 30" is expected.
  ///
  /// Returns null if cannot parse.
  static Point3i? tryParse(String text, {ParseCoordsInt? parser}) {
    try {
      return Point3i.parse(text, parser: parser);
    } on Exception {
      return null;
    }
  }

  /// A [PointFactory] creating [Point3i] instances.
  static const PointFactory<Point3i> coordinates =
      CastingPointFactory<Point3i>(Point3i.origin());

  /// A [PointFactory] creating [Point3i] instances.
  @Deprecated('Use coordinates instead')
  static const PointFactory<Point3i> geometry = coordinates;

  @override
  List<Object?> get props => [x, y, z];

  @override
  int get coordinateDimension => 3;

  @override
  int get spatialDimension => 3;

  @override
  bool get is3D => true;

  @override
  Coords get typeCoords => Coords.xyz;

  @override
  int operator [](int i) {
    switch (i) {
      case 0:
        return x;
      case 1:
        return y;
      case 2:
        return z;
      default:
        return 0;
    }
  }

  @override
  final int z;

  @override
  int? get optZ => z;

  @override
  Point3i copyWith({num? x, num? y, num? z, num? m}) => Point3i(
        x: x?.round() ?? this.x,
        y: y?.round() ?? this.y,
        z: z?.round() ?? this.z,
      );

  @override
  Point3i newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      Point3i(x: x.round(), y: y.round(), z: z?.round() ?? 0);

  @override
  Point3i newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
    return Point3i.from(coords, offset: offset);
  }

  @override
  Point3i transform(TransformPoint transform) => transform(this);

  @override
  String toString() => '$x,$y,$z';
}
