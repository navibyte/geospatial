// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base/aligned.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/geographic/geobox.dart';
import '/src/coordinates/projection/projection.dart';

import 'projected.dart';

/// A bounding box with [minX], [minY], [maxX] and [maxY] coordinates.
///
/// Optional [minZ] and [maxZ] for 3D boxes, and [minM] and [maxM] for
/// measured boxes can be provided too.
///
/// Supported coordinate value combinations by coordinate type:
///
/// Type | Bounding box values
/// ---- | ---------------
/// xy   | minX, minY, maxX, maxY
/// xyz  | minX, minY, minZ, maxX, maxY, maxZ
/// xym  | minX, minY, minM, maxX, maxY, maxM
/// xyzm | minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
@immutable
class ProjBox extends Box {
  final double _minX;
  final double _minY;
  final double? _minZ;
  final double? _minM;
  final double _maxX;
  final double _maxY;
  final double? _maxZ;
  final double? _maxM;

  /// A bounding box with [minX], [minY], [maxX] and [maxY] coordinates.
  ///
  /// Optional [minZ] and [maxZ] for 3D boxes, and [minM] and [maxM] for
  /// measured boxes can be provided too.
  const ProjBox({
    required double minX,
    required double minY,
    double? minZ,
    double? minM,
    required double maxX,
    required double maxY,
    double? maxZ,
    double? maxM,
  })  : _minX = minX,
        _minY = minY,
        _minZ = minZ,
        _minM = minM,
        _maxX = maxX,
        _maxY = maxY,
        _maxZ = maxZ,
        _maxM = maxM;

  /// A bounding box from parameters compatible with `CreateBox` function type.
  const ProjBox.create({
    required double minX,
    required double minY,
    double? minZ,
    double? minM,
    required double maxX,
    required double maxY,
    double? maxZ,
    double? maxM,
  })  : _minX = minX,
        _minY = minY,
        _minZ = minZ,
        _minM = minM,
        _maxX = maxX,
        _maxY = maxY,
        _maxZ = maxZ,
        _maxM = maxM;

  /// A minimum bounding box calculated from [positions].
  ///
  /// Throws FormatException if cannot create (ie. [positions] is empty).
  factory ProjBox.from(Iterable<Projected> positions) =>
      Box.createBoxFrom(positions, ProjBox.create);

  /// Builds a projected bounding box from [coords] starting from [offset].
  ///
  /// Supported coordinate value combinations by coordinate type:
  ///
  /// Type | Expected values
  /// ---- | ---------------
  /// xy   | minX, minY, maxX, maxY
  /// xyz  | minX, minY, minZ, maxX, maxY, maxZ
  /// xym  | minX, minY, minM, maxX, maxY, maxM
  /// xyzm | minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [coords] has 6 items, then xyz coordinates are assumed.
  ///
  /// Throws FormatException if coordinates are invalid.
  factory ProjBox.build(
    Iterable<num> coords, {
    int offset = 0,
    Coords? type,
  }) =>
      Box.buildBox(
        coords,
        to: ProjBox.create,
        offset: offset,
        type: type,
      );

  /// Parses a projected bounding box from [text].
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// Supported coordinate value combinations by coordinate type:
  ///
  /// Type | Expected values
  /// ---- | ---------------
  /// xy   | minX, minY, maxX, maxY
  /// xyz  | minX, minY, minZ, maxX, maxY, maxZ
  /// xym  | minX, minY, minM, maxX, maxY, maxM
  /// xyzm | minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [text] has 6 items, then xyz coordinates are assumed.
  ///
  /// Throws FormatException if coordinates are invalid.
  factory ProjBox.parse(
    String text, {
    Pattern? delimiter = ',',
    Coords? type,
  }) =>
      Box.parseBox(
        text,
        to: ProjBox.create,
        delimiter: delimiter,
        type: type,
      );

  @override
  double get minX => _minX;

  @override
  double get minY => _minY;

  @override
  double? get minZ => _minZ;

  @override
  double? get minM => _minM;

  @override
  double get maxX => _maxX;

  @override
  double get maxY => _maxY;

  @override
  double? get maxZ => _maxZ;

  @override
  double? get maxM => _maxM;

  /// The minimum position (or west-south) of this bounding box.
  @override
  Projected get min => Projected(
        x: _minX,
        y: _minY,
        z: _minZ,
        m: _minM,
      );

  /// The maximum position (or east-north) of this bounding box.
  @override
  Projected get max => Projected(
        x: _maxX,
        y: _maxY,
        z: _maxZ,
        m: _maxM,
      );

  @override
  double get width => maxX - minX;

  @override
  double get height => maxY - minY;

  @override
  ProjBox copyWith({
    double? minX,
    double? minY,
    double? minZ,
    double? minM,
    double? maxX,
    double? maxY,
    double? maxZ,
    double? maxM,
  }) =>
      ProjBox(
        minX: minX ?? _minX,
        minY: minY ?? _minY,
        minZ: minZ ?? _minZ,
        minM: minM ?? _minM,
        maxX: maxX ?? _maxX,
        maxY: maxY ?? _maxY,
        maxZ: maxZ ?? _maxZ,
        maxM: maxM ?? _maxM,
      );

  @override
  ProjBox copyByType(Coords type) => this.type == type
      ? this
      : ProjBox.create(
          minX: minX,
          minY: minY,
          minZ: type.is3D ? minZ ?? 0.0 : null,
          minM: type.isMeasured ? minM ?? 0.0 : null,
          maxX: maxX,
          maxY: maxY,
          maxZ: type.is3D ? maxZ ?? 0.0 : null,
          maxM: type.isMeasured ? maxM ?? 0.0 : null,
        );

  @override
  Projected aligned2D([Aligned align = Aligned.center]) =>
      Box.createAligned2D(this, Projected.create, align: align);

  @override
  Iterable<Projected> get corners2D =>
      Box.createCorners2D(this, Projected.create);

  /// Projects this projected bounding box to a geographic box using
  /// the inverse [projection].
  @override
  GeoBox project(Projection projection) {
    // get distinct corners (one, two or four) in 2D for the projected bbox
    final corners = corners2D;

    // unproject all corner positions (using the inverse projection)
    final unprojected = corners.map((pos) => pos.project(projection));

    // create an unprojected (geographic) bbox
    // (calculating min and max coords in all axes from corner positions)
    return GeoBox.from(unprojected);
  }

  @override
  int get spatialDimension => type.spatialDimension;

  @override
  int get coordinateDimension => type.coordinateDimension;

  @override
  bool get is3D => _minZ != null;

  @override
  bool get isMeasured => _minM != null;

  @override
  Coords get type => Coords.select(
        is3D: is3D,
        isMeasured: isMeasured,
      );

  @override
  bool operator ==(Object other) => other is Box && Box.testEquals(this, other);

  @override
  int get hashCode => Box.hash(this);
}
