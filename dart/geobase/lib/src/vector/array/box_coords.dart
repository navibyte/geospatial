// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: deprecated_member_use_from_same_package

part of 'coordinates.dart';

/// A geospatial bounding box as an iterable collection of coordinate values.
///
/// Such box is a valid [Box] implementation and represents coordinate values
/// also as a collection of `Iterable<double>` (containing 4, 6, or 8 items).
///
/// An instance of [BoxCoords] can be typed using extension methods:
/// * `asProjected`: returned as a `ProjBox` bounding box
/// * `asGeographic`: returned as a `Geographic` bounding box
///
/// See [Box] for description about supported coordinate values.
@Deprecated('Use Box instead')
abstract class BoxCoords extends Box with _CoordinatesMixin {
  @override
  final Iterable<double> _data;

  @override
  final Coords _type;

  /// A bounding box with coordinate values of [type] from [source].
  @Deprecated('Use Box.view instead')
  const BoxCoords(Iterable<double> source, {Coords type = Coords.xy})
      : _data = source,
        _type = type;

  /// A bounding box with coordinate values as a view backed by [source].
  ///
  /// An iterable collection of [source] may be represented by a [List] or any
  /// [Iterable] with efficient `length` and `elementAt` implementations.
  ///
  /// The [source] must contain 4, 6 or 8 coordinate values. Supported
  /// coordinate value combinations by coordinate [type] are:
  ///
  /// Type | Expected values
  /// ---- | ---------------
  /// xy   | minX, minY, maxX, maxY
  /// xyz  | minX, minY, minZ, maxX, maxY, maxZ
  /// xym  | minX, minY, minM, maxX, maxY, maxM
  /// xyzm | minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// Or when data is geographic:
  ///
  /// Type | Expected values
  /// ---- | ---------------
  /// xy   | west, south, east, north
  /// xyz  | west, south, minElev, east, north, maxElev
  /// xym  | west, south, minM, east, north, maxM
  /// xyzm | west, south, minElev, minM, east, north, maxElev, maxM
  @Deprecated('Use Box.view instead')
  factory BoxCoords.view(Iterable<double> source, {Coords type = Coords.xy}) {
    if (source.length != 2 * type.coordinateDimension) {
      throw invalidCoordinates;
    }
    return _BoxCoordsImpl.view(source, type: type);
  }

  /// A bounding box as an iterable collection of coordinate values.
  ///
  /// This factory is compatible with `CreateBox` function type.
  @Deprecated('Use Box.create instead')
  factory BoxCoords.create({
    required double minX,
    required double minY,
    double? minZ,
    double? minM,
    required double maxX,
    required double maxY,
    double? maxZ,
    double? maxM,
  }) {
    final is3D = minZ != null && maxZ != null;
    final isMeasured = minM != null && maxM != null;
    final type = Coords.select(is3D: is3D, isMeasured: isMeasured);
    final list = List<double>.filled(2 * type.coordinateDimension, 0);
    var i = 0;
    list[i++] = minX;
    list[i++] = minY;
    if (is3D) {
      list[i++] = minZ;
    }
    if (isMeasured) {
      list[i++] = minM;
    }
    list[i++] = maxX;
    list[i++] = maxY;
    if (is3D) {
      list[i++] = maxZ;
    }
    if (isMeasured) {
      list[i++] = maxM;
    }
    return BoxCoords.view(list, type: type);
  }

  /// A minimum bounding box calculated from [positions].
  ///
  /// Throws FormatException if cannot create (ie. [positions] is empty).
  @Deprecated('Use Box.from instead')
  factory BoxCoords.from(Iterable<Position> positions) =>
      Box.createBoxFrom(positions, BoxCoords.create);

  /// Parses a bounding box with coordinate values parsed from [text].
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// See [BoxCoords.view] for supported coordinate value combinations for
  /// coordinate [type].
  ///
  /// Throws FormatException if coordinates are invalid.
  @Deprecated('Use Box.parse instead')
  factory BoxCoords.parse(
    String text, {
    Pattern? delimiter = ',',
    Coords type = Coords.xy,
  }) =>
      BoxCoords.view(
        parseDoubleValues(text, delimiter: delimiter).toList(growable: false),
        type: type,
      );

  @override
  double get minX => _data.elementAt(0);

  @override
  double get minY => _data.elementAt(1);

  @override
  double? get minZ => is3D ? _data.elementAt(2) : null;

  @override
  double? get minM {
    final mIndex = _type.indexForM;
    return mIndex != null ? _data.elementAt(mIndex) : null;
  }

  @override
  double get maxX => _data.elementAt(coordinateDimension + 0);

  @override
  double get maxY => _data.elementAt(coordinateDimension + 1);

  @override
  double? get maxZ => is3D ? _data.elementAt(coordinateDimension + 2) : null;

  @override
  double? get maxM {
    final mIndex = _type.indexForM;
    return mIndex != null
        ? _data.elementAt(coordinateDimension + mIndex)
        : null;
  }

  @override
  BoxCoords copyWith({
    double? minX,
    double? minY,
    double? minZ,
    double? minM,
    double? maxX,
    double? maxY,
    double? maxZ,
    double? maxM,
  }) =>
      BoxCoords.create(
        minX: minX ?? this.minX,
        minY: minY ?? this.minY,
        minZ: minZ ?? this.minZ,
        minM: minM ?? this.minM,
        maxX: maxX ?? this.maxX,
        maxY: maxY ?? this.maxY,
        maxZ: maxZ ?? this.maxZ,
        maxM: maxM ?? this.maxM,
      );

  @override
  BoxCoords copyByType(Coords type) => this.type == type
      ? this
      : BoxCoords.create(
          minX: minX,
          minY: minY,
          minZ: type.is3D ? minZ ?? 0.0 : null,
          minM: type.isMeasured ? minM ?? 0.0 : null,
          maxX: maxX,
          maxY: maxY,
          maxZ: type.is3D ? maxZ ?? 0.0 : null,
          maxM: type.isMeasured ? maxM ?? 0.0 : null,
        );
}

@immutable
class _BoxCoordsImpl extends BoxCoords {
  const _BoxCoordsImpl.view(super.source, {super.type = Coords.xy}) : super();

  @override
  Iterable<double> get values => _data;

  @override
  Iterable<double> valuesByType(Coords type) =>
      type == this.type ? _data : Box.getValues(this, type: type);

  @override
  double get width => maxX - minX;

  @override
  double get height => maxY - minY;

  @override
  Position aligned2D([Aligned align = Aligned.center]) =>
      Box.createAligned2D(this, Projected.create, align: align);

  @override
  Iterable<Position> get corners2D =>
      Box.createCorners2D(this, Projected.create);

  /// Projects this bounding box to another box using [projection].
  @override
  BoxCoords project(Projection projection) {
    // get distinct corners (one, two or four) in 2D for the bounding bbox
    final corners = corners2D;

    // project all corner positions (using the projection)
    final projected = corners.map((pos) => pos.project(projection));

    // create a new bounding bbox
    // (calculating min and max coords in all axes from corner positions)
    return BoxCoords.from(projected);
  }

  @override
  PositionCoords get min => doCreateRange(
        _data,
        to: PositionCoords.view,
        type: type,
        start: 0,
        end: coordinateDimension,
      );

  @override
  PositionCoords get max => doCreateRange(
        _data,
        to: PositionCoords.view,
        type: type,
        start: coordinateDimension,
        end: 2 * coordinateDimension,
      );

  @override
  bool operator ==(Object other) => other is Box && Box.testEquals(this, other);

  @override
  int get hashCode => Box.hash(this);
}
