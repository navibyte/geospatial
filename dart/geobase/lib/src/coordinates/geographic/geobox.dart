// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base/aligned.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/projected/projbox.dart';
import '/src/coordinates/projection/projection.dart';

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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0)
  /// GeoBox(west: 10.0, south: 20.0, east: 15.0, north: 25.0);
  ///
  /// // a 3D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0, elev: 30.0 .. 35.0)
  /// const GeoBox(
  ///   west: 10.0, south: 20.0, minElev: 30.0,
  ///   east: 15.0, north: 25.0, maxElev: 35.0,
  /// );
  ///
  /// // a measured 2D box (lon: 10.0..15.0, lat: 20.0..25.0, m: 40.0..45.0)
  /// const GeoBox(
  ///   west: 10.0, south: 20.0, minM: 40.0,
  ///   east: 15.0, north: 25.0, maxM: 45.0,
  /// );
  ///
  /// // a measured 3D box
  /// // (lon: 10.0..15.0, lat: 20.0..25.0, elev: 30.0..35.0, m: 40.0..45.0)
  /// const GeoBox(
  ///   west: 10.0, south: 20.0, minElev: 30.0, minM: 40.0,
  ///   east: 15.0, north: 25.0, maxElev: 35.0, maxM: 45.0,
  /// );
  /// ```
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0)
  /// GeoBox.create(minX: 10.0, minY: 20.0, maxX: 15.0, maxY: 25.0);
  ///
  /// // a 3D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0, elev: 30.0 .. 35.0)
  /// const GeoBox.create(
  ///   minX: 10.0, minY: 20.0, minZ: 30.0,
  ///   maxX: 15.0, maxY: 25.0, maxZ: 35.0,
  /// );
  ///
  /// // a measured 2D box (lon: 10.0..15.0, lat: 20.0..25.0, m: 40.0..45.0)
  /// GeoBox.create(
  ///   minX: 10.0, minY: 20.0, minM: 40.0,
  ///   maxX: 15.0, maxY: 25.0, maxM: 45.0,
  /// );
  ///
  /// // a measured 3D box
  /// // (lon: 10.0..15.0, lat: 20.0..25.0, elev: 30.0..35.0, m: 40.0..45.0)
  /// GeoBox.create(
  ///   minX: 10.0, minY: 20.0, minZ: 30.0, minM: 40.0,
  ///   maxX: 15.0, maxY: 25.0, maxZ: 35.0, maxM: 45.0,
  /// );
  /// ```
  const GeoBox.create({
    required double minX,
    required double minY,
    double? minZ,
    double? minM,
    required double maxX,
    required double maxY,
    double? maxZ,
    double? maxM,
  })  : _west = minX,
        _south = minY,
        _minElev = minZ,
        _minM = minM,
        _east = maxX,
        _north = maxY,
        _maxElev = maxZ,
        _maxM = maxM;

  /// Creates a geographic bounding box by copying coordinates from [source].
  ///
  /// If [source] is an instance of [GeoBox] then it's returned.
  static GeoBox fromBox(Box source) =>
      source is GeoBox ? source : source.copyTo(GeoBox.create);

  /// A minimum bounding box calculated from [positions].
  ///
  /// Throws FormatException if cannot create (ie. [positions] is empty).
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0)
  /// GeoBox.from(
  ///   const [
  ///     Geographic(lon: 10.0, lat: 20.0),
  ///     Geographic(lon: 15.0, lat: 25.0),
  ///   ],
  /// );
  ///
  /// // a 3D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0, elev: 30.0 .. 35.0)
  /// GeoBox.from(
  ///   const [
  ///     Geographic(lon: 10.0, lat: 20.0, elev: 30.0),
  ///     Geographic(lon: 15.0, lat: 25.0, elev: 35.0),
  ///   ],
  /// );
  ///
  /// // a measured 2D box (lon: 10.0..15.0, lat: 20.0..25.0, m: 40.0..45.0)
  /// GeoBox.from(
  ///   const [
  ///     Geographic(lon: 10.0, lat: 20.0, m: 40.0),
  ///     Geographic(lon: 15.0, lat: 25.0, m: 45.0),
  ///   ],
  /// );
  ///
  /// // a measured 3D box
  /// // (lon: 10.0..15.0, lat: 20.0..25.0, elev: 30.0..35.0, m: 40.0..45.0)
  /// GeoBox.from(
  ///   const [
  ///     Geographic(lon: 10.0, lat: 20.0, elev: 30.0, m: 40.0),
  ///     Geographic(lon: 15.0, lat: 25.0, elev: 35.0, m: 45.0),
  ///   ],
  /// );
  /// ```
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
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0)
  /// GeoBox.build([10.0, 20.0, 15.0, 25.0]);
  ///
  /// // a 3D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0, elev: 30.0 .. 35.0)
  /// GeoBox.build([10.0, 20.0, 30.0, 15.0, 25.0, 35.0]);
  ///
  /// // a measured 2D box (lon: 10.0..15.0, lat: 20.0..25.0, m: 40.0..45.0)
  /// // (need to specify the coordinate type XYM)
  /// GeoBox.build([10.0, 20.0, 40.0, 15.0, 25.0, 45.0], type: Coords.xym);
  ///
  /// // a measured 3D box
  /// // (lon: 10.0..15.0, lat: 20.0..25.0, elev: 30.0..35.0, m: 40.0..45.0)
  /// GeoBox.build([10.0, 20.0, 30.0, 40.0, 15.0, 25.0, 35.0, 45.0]);
  /// ```
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
  /// xy   | west, south, east, north
  /// xyz  | west, south, minElev, east, north, maxElev
  /// xym  | west, south, minM, east, north, maxM
  /// xyzm | west, south, minElev, minM, east, north, maxElev, maxM
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and [text] has 6 items, then xyz coordinates are assumed.
  ///
  /// If [swapXY] is true, then swaps x and y (west <-> south, east <-> north)
  /// for the result.
  ///
  /// Throws FormatException if coordinates are invalid.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0)
  /// GeoBox.parse('10.0,20.0,15.0,25.0');
  ///
  /// // a 3D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0, elev: 30.0 .. 35.0)
  /// GeoBox.parse('10.0,20.0,30.0,15.0,25.0,35.0');
  ///
  /// // a measured 2D box (lon: 10.0..15.0, lat: 20.0..25.0, m: 40.0..45.0)
  /// // (need to specify the coordinate type XYM)
  /// GeoBox.parse('10.0,20.0,40.0,15.0,25.0,45.0', type: Coords.xym),
  ///
  /// // a measured 3D box
  /// // (lon: 10.0..15.0, lat: 20.0..25.0, elev: 30.0..35.0, m: 40.0..45.0)
  /// GeoBox.parse('10.0,20.0,30.0,40.0,15.0,25.0,35.0,45.0');
  ///
  /// // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0) using an alternative
  /// // delimiter
  /// GeoBox.parse('10.0;20.0;15.0;25.0', delimiter: ';');
  ///
  /// // a 2D box (lon: 10.0 .. 15.0, lat: 20.0 .. 25.0) from an array with y
  /// // (lat) before x (lon)
  /// GeoBox.parse('20.0,10.0,25.0,15.0', swapXY: true);
  /// ```
  factory GeoBox.parse(
    String text, {
    Pattern delimiter = ',',
    Coords? type,
    bool swapXY = false,
  }) =>
      Box.parseBox(
        text,
        to: GeoBox.create,
        delimiter: delimiter,
        type: type,
        swapXY: swapXY,
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
  double get minX => _west;

  @override
  double get minY => _south;

  @override
  double? get minZ => _minElev;

  @override
  double get maxX => _east;

  @override
  double get maxY => _north;

  @override
  double? get maxZ => _maxElev;

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
  double get width => spansAntimeridian ? 360.0 + east - west : east - west;

  @override
  double get height => north - south;

  /// True when this bounding box spans the antimeridian (that is
  /// "min-longitude" (west) is larger than "max-longitude" (east) as a number).
  ///
  /// See also RFC 7946 chapter 5 about bounding boxes in GeoJSON for reference.
  bool get spansAntimeridian => east < west;

  /// Returns two bounding boxes (one to west from antimeridian and another to
  /// east) when [spansAntimeridian] is true.
  ///
  /// When [spansAntimeridian] is false then returns this.
  ///
  /// It's guaranteed that no bounding box returned by this iterable spans
  /// antimeridian.
  Iterable<GeoBox> splitOnAntimeridian() sync* {
    if (spansAntimeridian) {
      // the part from antimeridian to west
      yield copyWith(maxX: 180.0); // set "east" ("maxX") to 180.0

      // the part from antimeridian to east
      yield copyWith(minX: -180.0); // set "west" ("minX") to -180.0
    } else {
      yield this;
    }
  }

  @override
  GeoBox copyWith({
    double? minX,
    double? minY,
    double? minZ,
    double? minM,
    double? maxX,
    double? maxY,
    double? maxZ,
    double? maxM,
  }) =>
      GeoBox(
        west: minX ?? _west,
        south: minY ?? _south,
        minElev: minZ ?? _minElev,
        minM: minM ?? _minM,
        east: maxX ?? _east,
        north: maxY ?? _north,
        maxElev: maxZ ?? _maxElev,
        maxM: maxM ?? _maxM,
      );

  @override
  GeoBox copyByType(Coords type) => this.type == type
      ? this
      : GeoBox.create(
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
  Geographic aligned2D([Aligned align = Aligned.center]) =>
      Box.createAligned2D(this, Geographic.create, align: align);

  @override
  Iterable<Geographic> get corners2D =>
      Box.createCorners2D(this, Geographic.create);

  /// Projects this geographic bounding box to a projected box using
  /// the forward [projection].
  @override
  ProjBox project(Projection projection) {
    // get distinct corners (one, two or four) in 2D for the geographic bbox
    final corners = corners2D;

    // project all corner positions (using the forward projection)
    final projected = corners.map((pos) => pos.project(projection));

    // create a projected bbox
    // (calculating min and max coords in all axes from corner positions)
    return ProjBox.from(projected);
  }

  @override
  int get spatialDimension => type.spatialDimension;

  @override
  int get coordinateDimension => type.coordinateDimension;

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
