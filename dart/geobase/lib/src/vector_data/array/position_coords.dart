// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'coordinates.dart';

/// A geospatial position as an iterable collection of coordinate values.
///
/// Such position is a valid [Position] implementation and represents
/// coordinate values also as a collection of `Iterable<double>` (containing 2,
/// 3, or 4 items).
///
/// The position can be typed as a projected position using [asProjected], and
/// as a geographic position using [asGeographic].
///
/// See [Position] for description about supported coordinate values.
///
/// See also specialized sub classes for projected coordinates:
///
/// Class  | 2D/3D | Coords | Values   | x | y | z | m
/// ------ | ----- | ------ | -------- | - | - | - | -
/// `XY`   | 2D    | 2      | `double` | + | + |   |
/// `XYZ`  | 3D    | 3      | `double` | + | + | + |
/// `XYM`  | 2D    | 3      | `double` | + | + |   | +
/// `XYZM` | 3D    | 4      | `double` | + | + | + | +
///
/// And there are also specialized sub classes for geographic coordinates:
///
/// Class         | 2D/3D | Coords | Values   | lon (x) | lat (y) | elev (z) | m
/// ------------- | ----- | ------ | -------- | ------- | ------- | -------- | -
/// `LonLat`      | 2D    | 2      | `double` |    +    |    +    |          |
/// `LonLatElev`  | 3D    | 3      | `double` |    +    |    +    |    +     |
/// `LonLatM`     | 2D    | 3      | `double` |    +    |    +    |          | +
/// `LonLatElevM` | 3D    | 4      | `double` |    +    |    +    |    +     | +
abstract class PositionCoords extends Position with _CoordinatesMixin {
  @override
  final Iterable<double> _data;

  @override
  final Coords _type;

  /// A geospatial position with coordinate values of [type] from [source].
  const PositionCoords(Iterable<double> source, {Coords type = Coords.xy})
      : _data = source,
        _type = type;

  /// A geospatial position with coordinate values as a view backed by [source].
  ///
  /// An iterable collection of [source] may be represented by a [List] or any
  /// [Iterable] with efficient `length` and `elementAt` implementations.
  ///
  /// The [source] must contain 2, 3 or 4 coordinate values. Supported
  /// coordinate value combinations by coordinate [type] are:
  ///
  /// Type | Expected values
  /// ---- | ---------------
  /// xy   | x, y
  /// xyz  | x, y, z
  /// xym  | x, y, m
  /// xyzm | x, y, z, m
  ///
  /// Or when data is geographic:
  ///
  /// Type | Expected values
  /// ---- | ---------------
  /// xy   | lon, lat
  /// xyz  | lon, lat, elev
  /// xym  | lon, lat, m
  /// xyzm | lon, lat, elev, m
  factory PositionCoords.view(Iterable<double> source, {Coords type}) =
      _PositionCoordsImpl.view;

  /// A geospatial position as an iterable collection of [x], [y], and optional
  /// [z] and [m] values.
  ///
  /// This factory is compatible with `CreatePosition` function type.
  factory PositionCoords.create({
    required num x,
    required num y,
    num? z,
    num? m,
  }) =>
      _doCreate(
        to: _PositionCoordsImpl.view,
        x: x,
        y: y,
        z: z,
        m: m,
      );

  /// Parses a geospatial position as an iterable collection parsed from [text].
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// See [PositionCoords.view] for supported coordinate value combinations for
  /// coordinate [type].
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [text] has 3 items, then xyz coordinates are assumed.
  ///
  /// Throws FormatException if coordinates are invalid.
  factory PositionCoords.parse(
    String text, {
    Pattern? delimiter = ',',
    Coords? type,
  }) =>
      _doParse(
        text,
        to: _PositionCoordsImpl.view,
        delimiter: delimiter,
        type: type,
      );

  @override
  double get x => _data.elementAt(0);

  @override
  double get y => _data.elementAt(1);

  @override
  double get z => is3D ? _data.elementAt(2) : 0.0;

  @override
  double? get optZ => is3D ? _data.elementAt(2) : null;

  @override
  double get m {
    final mIndex = _type.indexForM;
    return mIndex != null ? _data.elementAt(mIndex) : 0.0;
  }

  @override
  double? get optM {
    final mIndex = _type.indexForM;
    return mIndex != null ? _data.elementAt(mIndex) : null;
  }

  @override
  double operator [](int index) =>
      index >= 0 && index < coordinateDimension ? _data.elementAt(index) : 0.0;

  /// Returns this position typed as a projected position.
  ///
  /// If this position implements [Projected], then this may be returned.
  /// Otherwise a new instance with copied coordinate values is created.
  Projected get asProjected => copyTo(Projected.create);

  /// Returns this position typed as a geographic position.
  ///
  /// If this position implements [Geographic], then this may be returned.
  /// Otherwise a new instance with copied coordinate values is created.
  Geographic get asGeographic => copyTo(Geographic.create);

  // ---------------------------------------------------------------------------
  // Iterable<double> documentation overrides

  /// Returns a new iterator that allows iterating coordinate values of this
  /// position.
  ///
  /// There are 2, 3 or 4 coordinate values to iterate.
  ///
  /// For projected or cartesian coordinates, the coordinate ordering is:
  /// (x, y), (x, y, z), (x, y, m) or (x, y, z, m).
  ///
  /// For geographic coordinates, the coordinate ordering is:
  /// (lon, lat), (lon, lat, elev), (lon, lat, m) or (lon, lat, elev, m).
  @override
  Iterator<double> get iterator;

  /// A coordinate value by the coordinate axis [index].
  ///
  /// Returns zero when a coordinate axis is not available.
  ///
  /// For 2D coordinates the coordinate axis indexes are:
  ///
  /// Index | Projected | Geographic
  /// ----- | --------- | ----------
  /// 0     | x         | lon
  /// 1     | y         | lat
  /// 2     | m         | m
  ///
  /// For 3D coordinates the coordinate axis indexes are:
  ///
  /// Index | Projected | Geographic
  /// ----- | --------- | ----------
  /// 0     | x         | lon
  /// 1     | y         | lat
  /// 2     | z         | elev
  /// 3     | m         | m
  @override
  double elementAt(int index);

  /// The number of coordinate values (2, 3 or 4) for this position.
  ///
  /// Equals to [coordinateDimension].
  @override
  int get length;
}

/// A geospatial position as an iterable collection of coordinate values.
@immutable
class _PositionCoordsImpl extends PositionCoords {
  /// A geospatial position with coordinate values as a view backed by `source`.
  const _PositionCoordsImpl.view(super.source, {super.type = Coords.xy})
      : super();

  @override
  Iterable<double> get values => _data;

  @override
  _PositionCoordsImpl copyWith({num? x, num? y, num? z, num? m}) => _doCopyWith(
        from: this,
        to: _PositionCoordsImpl.view,
        x: x,
        y: y,
        z: z,
        m: m,
      );

  @override
  _PositionCoordsImpl transform(TransformPosition transform) =>
      transform.call(this);

  @override
  bool operator ==(Object other) =>
      other is Position && Position.testEquals(this, other);

  @override
  int get hashCode => Position.hash(this);
}

T _doCreate<T extends PositionCoords>({
  required _CreateAt<T> to,
  required num x,
  required num y,
  num? z,
  num? m,
}) {
  if (z != null) {
    // 3D coordinates
    if (m != null) {
      // 3D and measured coordinates
      final list = List<double>.filled(4, 0);
      list[0] = x.toDouble();
      list[1] = y.toDouble();
      list[2] = z.toDouble();
      list[3] = m.toDouble();
      return to.call(list, type: Coords.xyzm);
    } else {
      // 3D coordinates (not measured)
      final list = List<double>.filled(3, 0);
      list[0] = x.toDouble();
      list[1] = y.toDouble();
      list[2] = z.toDouble();
      return to.call(list, type: Coords.xyz);
    }
  } else {
    // 2D coordinates
    if (m != null) {
      // 2D and measured coordinates
      final list = List<double>.filled(3, 0);
      list[0] = x.toDouble();
      list[1] = y.toDouble();
      list[2] = m.toDouble();
      return to.call(list, type: Coords.xym);
    } else {
      // 2D coordinates (not measured)
      final list = List<double>.filled(2, 0);
      list[0] = x.toDouble();
      list[1] = y.toDouble();
      return to.call(list, type: Coords.xy);
    }
  }
}

T _doParse<T extends PositionCoords>(
  String text, {
  required _CreateAt<T> to,
  Pattern? delimiter = ',',
  Coords? type,
}) {
  final coords =
      parseDoubleValues(text, delimiter: delimiter).toList(growable: false);
  final len = coords.length;
  final coordType = type ?? Coords.fromDimension(len);
  if (len != coordType.coordinateDimension) {
    throw invalidCoordinates;
  }
  return to.call(
    coords,
    type: coordType,
  );
}

T _doCopyWith<T extends PositionCoords>({
  required T from,
  required _CreateAt<T> to,
  num? x,
  num? y,
  num? z,
  num? m,
}) {
  var size = 2;
  final newIs3D = from.is3D || z != null;
  if (newIs3D) size++;
  final newIsMeasured = from.isMeasured || m != null;
  if (newIsMeasured) size++;
  final newType = Coords.select(is3D: newIs3D, isMeasured: newIsMeasured);

  final list = List<double>.filled(size, 0);
  list[0] = x?.toDouble() ?? from.x;
  list[1] = y?.toDouble() ?? from.y;
  if (newIs3D) {
    list[2] = z?.toDouble() ?? from.z;
  }
  if (newIsMeasured) {
    list[newType.indexForM!] = m?.toDouble() ?? from.m;
  }

  return to.call(
    list,
    type: newType,
  );
}
