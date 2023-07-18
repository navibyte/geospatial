// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base/aligned.dart';
import '/src/coordinates/base/box.dart';

import 'dms.dart';
import 'geographic.dart';

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
///
/// Supported coordinate value combinations by coordinate type:
///
/// Type | Bounding box values
/// ---- | ---------------
/// xy   | west, south, east, north
/// xyz  | west, south, minElev, east, north, maxElev
/// xym  | west, south, minM, east, north, maxM
/// xyzm | west, south, minElev, minM, east, north, maxElev, maxM
@immutable
class GeoBox extends Box {
  final double _west;
  final double _south;
  final double? _minElev;
  final double? _minM;
  final double _east;
  final double _north;
  final double? _maxElev;
  final double? _maxM;

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

  /// A bounding box from parameters compatible with `CreateBox` function type.
  GeoBox.create({
    required num minX,
    required num minY,
    num? minZ,
    num? minM,
    required num maxX,
    required num maxY,
    num? maxZ,
    num? maxM,
  })  : _west = minX.toDouble(),
        _south = minY.toDouble(),
        _minElev = minZ?.toDouble(),
        _minM = minM?.toDouble(),
        _east = maxX.toDouble(),
        _north = maxY.toDouble(),
        _maxElev = maxZ?.toDouble(),
        _maxM = maxM?.toDouble();

  /// A minimum bounding box calculated from [positions].
  ///
  /// Throws FormatException if cannot create (ie. [positions] is empty).
  factory GeoBox.from(Iterable<Geographic> positions) =>
      Box.createBoxFrom(positions, GeoBox.create);

  /// Builds a geographic bounding box from [coords] starting from [offset].
  ///
  /// Supported coordinate value combinations by coordinate type:
  ///
  /// Type | Expected values
  /// ---- | ---------------
  /// xy   | west, south, east, north
  /// xyz  | west, south, minElev, east, north, maxElev
  /// xym  | west, south, minM, east, north, maxM
  /// xyzm | west, south, minElev, minM, east, north, maxElev, maxM
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [coords] has 6 items, then xyz coordinates are assumed.
  ///
  /// Throws FormatException if coordinates are invalid.
  factory GeoBox.build(
    Iterable<num> coords, {
    int offset = 0,
    Coords? type,
  }) =>
      Box.buildBox(
        coords,
        to: GeoBox.create,
        offset: offset,
        type: type,
      );

  /// Parses a geographic bounding box from [text].
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
  factory GeoBox.parse(
    String text, {
    Pattern? delimiter = ',',
    Coords? type,
  }) =>
      Box.parseBox(
        text,
        to: GeoBox.create,
        delimiter: delimiter,
        type: type,
      );

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

  @override
  num get minX => _west;

  @override
  num get minY => _south;

  @override
  num? get minZ => _minElev;

  @override
  num get maxX => _east;

  @override
  num get maxY => _north;

  @override
  num? get maxZ => _maxElev;

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
  num get width => east - west;

  @override
  num get height => north - south;

  @override
  Geographic aligned2D([Aligned align = Aligned.center]) =>
      Box.createAligned2D(this, Geographic.create, align: align);

  @override
  Iterable<Geographic> get corners2D =>
      Box.createCorners2D(this, Geographic.create);

  @override
  int get spatialDimension => type.spatialDimension;

  @override
  int get coordinateDimension => type.coordinateDimension;

/*
  @override
  bool get isGeographic => true;
*/

  @override
  bool get is3D => _minElev != null;

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

  // ---------------------------------------------------------------------------
  // Special coordinate formats etc.

  /// Parses a geographic bounding box from [west], [south], [east] and [north]
  /// values that are formatted as specified (and parsed) by [format].
  ///
  /// By default the [Dms] class is used as the format.
  ///
  /// Optionally [minElev] and [maxElev] for 3D boxes, and [minM] and [maxM] for
  /// measured boxes are parsed using the standard `double.tryParse` method.
  factory GeoBox.parseDms({
    DmsFormat format = const Dms(),
    required String west,
    required String south,
    String? minElev,
    String? minM,
    required String east,
    required String north,
    String? maxElev,
    String? maxM,
  }) =>
      GeoBox(
        west: format.parse(west),
        south: format.parse(south),
        minElev: minElev != null ? double.tryParse(minElev) : null,
        minM: minM != null ? double.tryParse(minM) : null,
        east: format.parse(east),
        north: format.parse(north),
        maxElev: maxElev != null ? double.tryParse(maxElev) : null,
        maxM: maxM != null ? double.tryParse(maxM) : null,
      );

  /// Formats [west] according to [format].
  String westDms([DmsFormat format = const Dms()]) => format.lon(west);

  /// Formats [south] according to [format].
  String southDms([DmsFormat format = const Dms()]) => format.lat(south);

  /// Formats [east] according to [format].
  String eastDms([DmsFormat format = const Dms()]) => format.lon(east);

  /// Formats [north] according to [format].
  String northDms([DmsFormat format = const Dms()]) => format.lat(north);
}
