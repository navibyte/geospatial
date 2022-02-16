// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/base/codes.dart';
import '/src/utils/tolerance.dart';

import 'box.dart';
import 'geographic.dart';
import 'projbox.dart';

/// A geographic bounding box with [west], [south], [east] and [north] values.
///
/// West and east represents geographic longitude coordinates values. South and
/// north represents geographic latitude coordinates values.
///
/// For geographic bounding boxes `(west-longitude, south-latitude)` position
/// represents the most **southwesterly** point, and
/// `(east-longitude, north-latitude)` position represents the more
/// **northeasterly** point. When a bounding box spans the antimeridian, it's
/// possible that "min-longitude" (west) is larger than "max-longitude" (east)
/// as a number. See also RFC 7946 chapter 5 about bounding boxes in GeoJSON for
/// reference.
///
/// Optional [minElev] and [maxElev] for 3D boxes, and [minM] and [maxM] for
/// measured boxes can be provided too.
@immutable
class GeoBox extends Box {
  /// A geographic bounding box with [west], [south], [east] and [north] values.
  ///
  /// West and east represents geographic longitude coordinates values. South
  /// and north represents geographic latitude coordinates values.
  ///
  /// For geographic bounding boxes `(west-longitude, south-latitude)` position
  /// represents the most **southwesterly** point, and
  /// `(east-longitude, north-latitude)` position represents the more
  /// **northeasterly** point. When a bounding box spans the antimeridian, it's
  /// possible that "min-longitude" (west) is larger than "max-longitude" (east)
  /// as a number. See also RFC 7946 chapter 5 about bounding boxes in GeoJSON
  /// for reference.
  ///
  /// Optional [minElev] and [maxElev] for 3D boxes, and [minM] and [maxM] for
  /// measured boxes can be provided too.
  const GeoBox({
    required double west,
    required double south,
    double? minElev,
    double? minM,
    required double east,
    required double north,
    double? maxElev,
    double? maxM,
  })  : _west = west,
        _south = south,
        _minElev = minElev,
        _minM = minM,
        _east = east,
        _north = north,
        _maxElev = maxElev,
        _maxM = maxM;

  final double _west;
  final double _south;
  final double? _minElev;
  final double? _minM;
  final double _east;
  final double _north;
  final double? _maxElev;
  final double? _maxM;

  /// The west coordinate as geographic longitude.
  double get west => _west;

  /// The south coordinate as geographic latitude.
  double get south => _south;

  /// The minimum elevation (or altitude) coordinate in meters optionally.
  ///
  /// Returns null if not available.
  ///
  /// You can also use [is3D] to check whether elevation coordinate available.
  double? get minElev => _minElev;

  @override
  double? get minM => _minM;

  /// The east coordinate as geographic longitude.
  double get east => _east;

  /// The north coordinate as geographic latitude.
  double get north => _north;

  /// The maximum elevation (or altitude) coordinate in meters optionally.
  ///
  /// Returns null if not available.
  ///
  /// You can also use [is3D] to check whether elevation coordinate available.
  double? get maxElev => _maxElev;

  @override
  double? get maxM => _maxM;

  /// The "west-south" geographic position of this bounding box.
  ///
  /// For geographic bounding boxes this represents the most **southwesterly**
  /// point. When a bounding box spans the antimeridian, it's possible that
  /// "min-longitude" (west) is larger than "max-longitude" (east) as a number.
  /// See also RFC 7946 chapter 5 about bounding boxes in GeoJSON for reference.
  @override
  Geographic get min => Geographic(
        lon: _west,
        lat: _south,
        elev: _minElev,
        m: _minM,
      );

  /// The "east-north" geographic position of this bounding box.
  ///
  /// For geographic bounding boxes this represents the more **northeasterly**
  /// point in relation to [min] that represents the most **southwesterly**
  /// point. When a bounding box spans the antimeridian, it's possible that
  /// "min-longitude" (west) is larger than "max-longitude" (east) as a number.
  /// See also RFC 7946 chapter 5 about bounding boxes in GeoJSON for reference.
  @override
  Geographic get max => Geographic(
        lon: _east,
        lat: _north,
        elev: _maxElev,
        m: _maxM,
      );

  @override
  ProjBox get asBox => ProjBox(
        minX: _west,
        minY: _south,
        minZ: _minElev,
        minM: _minM,
        maxX: _east,
        maxY: _north,
        maxZ: _maxElev,
        maxM: _maxM,
      );

  @override
  int get spatialDimension => typeCoords.spatialDimension;

  @override
  int get coordinateDimension => typeCoords.coordinateDimension;

  @override
  bool get isGeographic => true;

  @override
  bool get is3D => _minElev != null;

  @override
  bool get isMeasured => _minM != null;

  @override
  Coords get typeCoords => CoordsExtension.select(
        isGeographic: isGeographic,
        is3D: is3D,
        isMeasured: isMeasured,
      );

  @override
  String toString() {
    switch (typeCoords) {
      case Coords.lonLat:
        return '$_west,$_south,$_east,$_north';
      case Coords.lonLatElev:
        return '$_west,$_south,$_minElev,$_east,$_north,$_maxElev';
      case Coords.lonLatM:
        return '$_west,$_south,$_minM,$_east,$_east,$_maxM';
      case Coords.lonLatElevM:
        return '$_west,$_south,$_minElev,$_minM,'
            '$_east,$_north,$_maxElev,$_maxM';
      case Coords.xy:
      case Coords.xyz:
      case Coords.xym:
      case Coords.xyzm:
        return '<not projected>';
    }
  }

  @override
  bool operator ==(Object other) =>
      other is GeoBox && GeoBox.testEquals(this, other);

  @override
  int get hashCode => GeoBox.hash(this);

  @override
  bool equals2D(Box other, {num? toleranceHoriz}) =>
      other is GeoBox &&
      GeoBox.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

  @override
  bool equals3D(
    Box other, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) =>
      other is GeoBox &&
      GeoBox.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  // ---------------------------------------------------------------------------
  // Static methods with default logic, used by GeoBox itself too.

  /// True if [box1] and [box2] equals by testing all coordinate values.
  static bool testEquals(GeoBox box1, GeoBox box2) =>
      box1.west == box2.west &&
      box1.south == box2.south &&
      box1.minElev == box2.minElev &&
      box1.minM == box2.minM &&
      box1.east == box2.east &&
      box1.north == box2.north &&
      box1.maxElev == box2.maxElev &&
      box1.maxM == box2.maxM;

  /// The hash code for [box].
  static int hash(GeoBox box) => Object.hash(
        box.west,
        box.south,
        box.minElev,
        box.minM,
        box.east,
        box.north,
        box.maxElev,
        box.maxM,
      );

  /// True if positions [box1] and [box2] equals by testing 2D coordinates only.
  static bool testEquals2D(
    GeoBox box1,
    GeoBox box2, {
    num? toleranceHoriz,
  }) {
    assertTolerance(toleranceHoriz);
    return toleranceHoriz != null
        ? (box1.west - box2.west).abs() <= toleranceHoriz &&
            (box1.south - box2.south).abs() <= toleranceHoriz &&
            (box1.east - box2.east).abs() <= toleranceHoriz &&
            (box1.north - box2.north).abs() <= toleranceHoriz
        : box1.west == box2.west &&
            box1.south == box2.south &&
            box1.east == box2.east &&
            box1.north == box2.north;
  }

  /// True if positions [box1] and [box2] equals by testing 3D coordinates only.
  static bool testEquals3D(
    GeoBox box1,
    GeoBox box2, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) {
    assertTolerance(toleranceVert);
    if (!GeoBox.testEquals2D(box1, box2, toleranceHoriz: toleranceHoriz)) {
      return false;
    }
    if (!box1.is3D || !box1.is3D) {
      return false;
    }
    if (toleranceVert != null) {
      final minElev1 = box1.minElev;
      final maxElev1 = box1.maxElev;
      final minElev2 = box2.minElev;
      final maxElev2 = box2.maxElev;
      return minElev1 != null &&
          maxElev1 != null &&
          minElev2 != null &&
          maxElev2 != null &&
          (minElev1 - minElev2).abs() <= toleranceVert &&
          (maxElev1 - maxElev2).abs() <= toleranceVert;
    } else {
      return box1.minElev == box2.minElev && box1.maxElev == box2.maxElev;
    }
  }
}
