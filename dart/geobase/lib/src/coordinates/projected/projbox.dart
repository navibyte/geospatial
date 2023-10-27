// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/common/codes/coords.dart';
import '/src/coordinates/base/aligned.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_scheme.dart';
import '/src/coordinates/geographic/geobox.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/coord_calculations_cartesian.dart';

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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D box
  /// ProjBox(minX: 10.0, minY: 20.0, maxX: 15.0, maxY: 25.0);
  ///
  /// // a 3D box
  /// ProjBox(
  ///   minX: 10.0, minY: 20.0, minZ: 30.0,
  ///   maxX: 15.0, maxY: 25.0, maxZ: 35.0,
  /// );
  ///
  /// // a measured 2D box
  /// ProjBox(
  ///   minX: 10.0, minY: 20.0, minM: 40.0,
  ///   maxX: 15.0, maxY: 25.0, maxM: 45.0,
  /// );
  ///
  /// // a measured 3D box
  /// ProjBox(
  ///   minX: 10.0, minY: 20.0, minZ: 30.0, minM: 40.0,
  ///   maxX: 15.0, maxY: 25.0, maxZ: 35.0, maxM: 45.0,
  /// );
  /// ```
  ///
  /// This default constructor is equivalent to [ProjBox.create].
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D box
  /// ProjBox.create(minX: 10.0, minY: 20.0, maxX: 15.0, maxY: 25.0);
  ///
  /// // a 3D box
  /// ProjBox.create(
  ///   minX: 10.0, minY: 20.0, minZ: 30.0,
  ///   maxX: 15.0, maxY: 25.0, maxZ: 35.0,
  /// );
  ///
  /// // a measured 2D box
  /// ProjBox.create(
  ///   minX: 10.0, minY: 20.0, minM: 40.0,
  ///   maxX: 15.0, maxY: 25.0, maxM: 45.0,
  /// );
  ///
  /// // a measured 3D box
  /// ProjBox.create(
  ///   minX: 10.0, minY: 20.0, minZ: 30.0, minM: 40.0,
  ///   maxX: 15.0, maxY: 25.0, maxZ: 35.0, maxM: 45.0,
  /// );
  /// ```
  ///
  /// This constructor is equivalent to the default contructor [ProjBox.new].
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

  /// Creates a projected bounding box by copying coordinates from [source].
  ///
  /// If [source] is an instance of [ProjBox] then it's returned.
  static ProjBox fromBox(Box source) =>
      source is ProjBox ? source : source.copyTo(ProjBox.create);

  /// A minimum bounding box calculated from [positions].
  ///
  /// Throws FormatException if cannot create (ie. [positions] is empty).
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
  /// ProjBox.from(
  ///   const [
  ///     Projected(x: 10.0, y: 20.0),
  ///     Projected(x: 15.0, y: 25.0),
  ///   ],
  /// );
  ///
  /// // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
  /// ProjBox.from(
  ///   const [
  ///     Projected(x: 10.0, y: 20.0, z: 30.0),
  ///     Projected(x: 15.0, y: 25.0, z: 35.0),
  ///   ],
  /// );
  ///
  /// // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
  /// ProjBox.from(
  ///   const [
  ///     Projected(x: 10.0, y: 20.0, m: 40.0),
  ///     Projected(x: 15.0, y: 25.0, m: 45.0),
  ///   ],
  /// );
  ///
  /// // a measured 3D box
  /// // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
  /// ProjBox.from(
  ///   const [
  ///     Projected(x: 10.0, y: 20.0, z: 30.0, m: 40.0),
  ///     Projected(x: 15.0, y: 25.0, z: 35.0, m: 45.0),
  ///   ],
  /// );
  /// ```
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
  /// ProjBox.build([10.0, 20.0, 15.0, 25.0]);
  ///
  /// // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
  /// ProjBox.build([10.0, 20.0, 30.0, 15.0, 25.0, 35.0]);
  ///
  /// // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
  /// // (need to specify the coordinate type XYM)
  /// ProjBox.build([10.0, 20.0, 40.0, 15.0, 25.0, 45.0], type: Coords.xym);
  ///
  /// // a measured 3D box
  /// // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
  /// ProjBox.build([10.0, 20.0, 30.0, 40.0, 15.0, 25.0, 35.0, 45.0]);
  /// ```
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
  /// If [swapXY] is true, then swaps x and y for the result.
  ///
  /// Throws FormatException if coordinates are invalid.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
  /// ProjBox.parse('10.0,20.0,15.0,25.0');
  ///
  /// // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
  /// ProjBox.parse('10.0,20.0,30.0,15.0,25.0,35.0');
  ///
  /// // a measured 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, m: 40.0 .. 45.0)
  /// // (need to specify the coordinate type XYM)
  /// ProjBox.parse('10.0,20.0,40.0,15.0,25.0,45.0', type: Coords.xym);
  ///
  /// // a measured 3D box
  /// // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
  /// ProjBox.parse('10.0,20.0,30.0,40.0,15.0,25.0,35.0,45.0');
  ///
  /// // a 2D box (x: 10.0..15.0, y: 20.0..25.0) using an alternative delimiter
  /// ProjBox.parse('10.0;20.0;15.0;25.0', delimiter: ';');
  ///
  /// // a 2D box (x: 10.0..15.0, y: 20.0..25.0) from an array with y before x
  /// ProjBox.parse('20.0,10.0,25.0,15.0', swapXY: true);
  /// ```
  factory ProjBox.parse(
    String text, {
    Pattern delimiter = ',',
    Coords? type,
    bool swapXY = false,
  }) =>
      Box.parseBox(
        text,
        to: ProjBox.create,
        delimiter: delimiter,
        type: type,
        swapXY: swapXY,
      );

  @override
  PositionScheme get conforming => Projected.scheme;

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

  @override
  ProjBox merge(Box other) => Box.createMerged(this, other, ProjBox.create);

  @override
  Iterable<ProjBox> splitUnambiguously() => [this];

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

  /// Returns a bounding box with min and max coordinate values of this summed
  /// with coordinate values of [addend].
  ///
  /// Examples:
  ///
  /// ```dart
  /// // Returns: `ProjBox(minX: 3.0, minY: 0.0, maxX: 4.0, maxY: 1.0))`
  /// ProjBox(minX: 1.0, minY: 1.0, maxX: 2.0, maxY: 2.0) +
  ///   Projected(x: 2.0, y: -1.0);
  /// ```
  @override
  ProjBox operator +(Position addend) =>
      cartesianBoxSum(this, addend, to: ProjBox.create);

  /// Returns a bounding box with min and max coordinate values of this
  /// subtracted with coordinate values of [subtract].
  ///
  /// Examples:
  ///
  /// ```dart
  /// // Returns: `ProjBox(minX: -1.0, minY: 2.0, maxX: 0.0, maxY: 3.0))`
  /// ProjBox(minX: 1.0, minY: 1.0, maxX: 2.0, maxY: 2.0) -
  ///   Projected(x: 2.0, y: -1.0);
  /// ```
  @override
  ProjBox operator -(Position subtract) =>
      cartesianBoxSubtract(this, subtract, to: ProjBox.create);

  @override
  ProjBox operator *(double factor) =>
      cartesianBoxScale(this, factor: factor, to: ProjBox.create);

  @override
  ProjBox operator -() => cartesianBoxNegate(this, to: ProjBox.create);

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
