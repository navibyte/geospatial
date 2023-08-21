// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_multiple_declarations_per_line

import 'dart:math' as math;

import '/src/codes/coords.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/format_validation.dart';
import '/src/utils/num.dart';
import '/src/utils/tolerance.dart';

import 'aligned.dart';
import 'position.dart';
import 'positionable.dart';

/// Creates a new bounding box from [minX], [minY], [maxX] and [maxY] values.
///
/// Optional [minZ] and [maxZ] for 3D boxes, and [minM] and [maxM] for
/// measured boxes can be provided too.
///
/// For projected or cartesian bounding boxes (`ProjBox`), coordinates axis are
/// applied as is.
///
/// For geographic bounding boxes (`GeoBox`), coordinates are applied as:
/// `minX` => `west`, `minY` => `south`, `minZ` => `minElev`, `minM` => `minM`,
/// `maxX` => `east`, `maxY` => `north`, `maxZ` => `maxElev`, `maxM` => `maxM`
typedef CreateBox<T extends Box> = T Function({
  required double minX,
  required double minY,
  double? minZ,
  double? minM,
  required double maxX,
  required double maxY,
  double? maxZ,
  double? maxM,
});

/// A base interface for axis-aligned bounding boxes with min & max coordinates.
///
/// This interface defines min and max coordinate values only for the m axis.
/// Sub classes define min and max coordinate values for other axes (x, y and z
/// in projected coordinate systems, and longitude, latitude and elevation in
/// geographic coordinate systems).
///
/// The known sub classes are `ProjBox` (with minX, minY, minZ, minM, maxX,
/// maxY, maxZ and maxM coordinates) and `GeoBox` (with west, south, minElev,
/// minM, east, north, maxElev and maxM coordinates).
///
/// Supported coordinate value combinations by coordinate type:
///
/// Type | Bounding box values
/// ---- | ---------------
/// xy   | minX, minY, maxX, maxY
/// xyz  | minX, minY, minZ, maxX, maxY, maxZ
/// xym  | minX, minY, minM, maxX, maxY, maxM
/// xyzm | minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
///
/// For geographic bounding boxes:
///
/// Type | Bounding box values
/// ---- | ---------------
/// xy   | west, south, east, north
/// xyz  | west, south, minElev, east, north, maxElev
/// xym  | west, south, minM, east, north, maxM
/// xyzm | west, south, minElev, minM, east, north, maxElev, maxM
///
/// Sub classes containing coordinate values mentioned above, should implement
/// equality and hashCode methods as:
///
/// ```dart
/// @override
/// bool operator ==(Object other) =>
///      other is Box && Box.testEquals(this, other);
///
/// @override
/// int get hashCode => Box.hash(this);
/// ```
abstract class Box extends Positionable {
  /// Default `const` constructor to allow extending this abstract class.
  const Box();

  /// The minimum x (or west) coordinate.
  ///
  /// For geographic coordinates minX represents *west* longitude.
  double get minX;

  /// The minimum y (or south) coordinate.
  ///
  /// For geographic coordinates minY represents *south* latitude.
  double get minY;

  /// The minimum z coordinate optionally. Returns null if not available.
  ///
  /// For geographic coordinates minZ represents minimum elevation or altitude.
  ///
  /// You can also use [is3D] to check whether z coordinate available.
  double? get minZ;

  /// The minimum m coordinate optionally. Returns null if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available.
  double? get minM;

  /// The maximum x (or east) coordinate.
  ///
  /// For geographic coordinates maxX represents *east* longitude.
  double get maxX;

  /// The maximum y (or north) coordinate.
  ///
  /// For geographic coordinates maxY represents *north* latitude.
  double get maxY;

  /// The maximum z coordinate optionally. Returns null if not available.
  ///
  /// For geographic coordinates maxZ represents maximum elevation or altitude.
  ///
  /// You can also use [is3D] to check whether z coordinate available.
  double? get maxZ;

  /// The maximum m coordinate optionally. Returns null if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available.
  double? get maxM;

  /// The minimum position (or west-south) of this bounding box.
  Position get min;

  /// The maximum position (or east-north) of this bounding box.
  Position get max;

  /// Copies this box to a new box created by the [factory].
  R copyTo<R extends Box>(CreateBox<R> factory) => factory.call(
        minX: minX,
        minY: minY,
        minZ: minZ,
        minM: minM,
        maxX: maxX,
        maxY: maxY,
        maxZ: maxZ,
        maxM: maxM,
      );

  /// Copies this box with optional attributes overriding values.
  ///
  /// When copying `GeoBox` then coordinates has correspondence:
  /// `minX` => `west`, `maxX` => `east`, 
  /// `minY` => `south`, `maxY` => `north`,
  /// `minZ` => `minElev`, `maxElev` => `maxElev`,
  /// `minM` => `minM`, `maxM` => `maxM`
  Box copyWith({
    double? minX,
    double? minY,
    double? minZ,
    double? minM,
    double? maxX,
    double? maxY,
    double? maxZ,
    double? maxM,
  });

  /// The width of the bounding box, equals to `maxX - minX`.
  double get width;

  /// The height of the bounding box, equals to `maxY - minY`.
  double get height;

  /// Returns an aligned 2D position relative to this box.
  Position aligned2D([Aligned align = Aligned.center]);

  /// Returns all distinct (in 2D) corners for this axis aligned bounding box.
  ///
  /// May return 1 (when `min == max`), 2 (when either or both 2D coordinates
  /// equals between min and max) or 4 positions (otherwise).
  Iterable<Position> get corners2D;

  /// Projects this bounding box to another box using [projection].
  ///
  /// Subtypes may specify a more accurate bounding box type for the returned
  /// object (for example a *geographic* bounding box would return a *projected*
  /// box when forward-projecting, and other way when inverse-projecting).
  Box project(Projection projection);

  /// True if this box equals with [other] by testing 2D coordinates only.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals2D(Box other, {double toleranceHoriz = defaultEpsilon}) =>
      Box.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

  /// True if this box equals with [other] by testing 3D coordinates only.
  ///
  /// Returns false if this or [other] is not a 3D box.
  ///
  /// Differences on 2D coordinate values (ie. x and y, or lon and lat) between
  /// this and [other] must be within [toleranceHoriz].
  ///
  /// Differences on vertical coordinate values (ie. z or elev) between
  /// this and [other] must be within [toleranceVert].
  ///
  /// Tolerance values must be positive (>= 0.0).
  bool equals3D(
    Box other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) =>
      Box.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  /// Returns true if this bounding box intersects with [other] box in 2D.
  ///
  /// Only x ja y (or lon and lat) are compared on intersection calculation.
  bool intersects2D(Box other) => Box.testIntersects2D(this, other);

  /// Returns true if this bounding box intesects with [other] box.
  ///
  /// X ja y (or lon and lat) are always compared on intersection calculation.
  ///
  /// This and [other] must equal on [is3D] and [isMeasured] properties. Z (or
  /// elev) is further compared when both has z coordinates, and m is compared
  /// when both has m coordinates.
  bool intersects(Box other) => Box.testIntersects(this, other);

  /// Returns true if this bounding box intesects with [point] in 2D.
  ///
  /// Only x ja y (or lon and lat) are compared on intersection calculation.
  bool intersectsPoint2D(Position point) =>
      Box.testIntersectsPoint2D(this, point);

  /// Returns true if this bounding box intesects with [point].
  ///
  /// X ja y (or lon and lat) are always compared on intersection calculation.
  ///
  /// This and [point] must equal on [is3D] and [isMeasured] properties. Z (or
  /// elev) is further compared when both has z coordinates, and m is compared
  /// when both has m coordinates.
  bool intersectsPoint(Position point) => Box.testIntersectsPoint(this, point);

  /// Returns coordinate values as a string separated by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// Set [swapXY] to true to print y (or latitude) before x (or longitude).
  ///
  /// A sample with default parameters (for a 2D bounding box):
  /// `10.1,10.1,20.2,20.2`
  String toText({String delimiter = ',', int? decimals, bool swapXY = false}) {
    final buf = StringBuffer();
    Box.writeValues(
      this,
      buf,
      delimiter: delimiter,
      decimals: decimals,
      swapXY: swapXY,
    );
    return buf.toString();
  }

  @override
  String toString() {
    switch (type) {
      case Coords.xy:
        return '$minX,$minY,$maxX,$maxY';
      case Coords.xyz:
        return '$minX,$minY,$minZ,$maxX,$maxY,$maxZ';
      case Coords.xym:
        return '$minX,$minY,$minM,$maxX,$maxY,$maxM';
      case Coords.xyzm:
        return '$minX,$minY,$minZ,$minM,$maxX,$maxY,$maxZ,$maxM';
    }
  }

  // ---------------------------------------------------------------------------
  // Static methods with default logic, used by Box, ProjBox and GeoBox.

  /// Creates a bounding box of [R] from [box] (of [R] or `Iterable<num>`).
  ///
  /// If [box] is [R] and with compatible coordinate type already, then it's
  /// returned.  Other `Box` instances are copied as [R].
  ///
  /// If [box] is `Iterable<num>`, then a bounding box instance is created using
  /// the factory function [to]. Supported coordinate value combinations by
  /// coordinate type:
  ///
  /// Type | Expected values
  /// ---- | ---------------
  /// xy   | minX, minY, maxX, maxY
  /// xyz  | minX, minY, minZ, maxX, maxY, maxZ
  /// xym  | minX, minY, minM, maxX, maxY, maxM
  /// xyzm | minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// Use an optional [type] to explicitely set the coordinate type. If not
  /// provided and an iterable has 6 items, then xyz coordinates are assumed.
  ///
  /// Otherwise throws `FormatException`.
  static R createFromObject<R extends Box>(
    Object box, {
    required CreateBox<R> to,
    Coords? type,
  }) {
    if (box is Box) {
      if (box is R && (type == null || type == box.type)) {
        // box is of R and with compatiable coord type
        return box;
      } else {
        if (type == null) {
          // create a copy with same coordinate values
          return to.call(
            minX: box.minX,
            minY: box.minY,
            minZ: box.minZ,
            minM: box.minM,
            maxX: box.maxX,
            maxY: box.maxY,
            maxZ: box.maxZ,
            maxM: box.maxM,
          );
        } else {
          // create a copy with z and m selected if coord type suggests so
          return to.call(
            minX: box.minX,
            minY: box.minY,
            minZ: type.is3D ? box.minZ ?? 0 : null,
            minM: type.isMeasured ? box.minM ?? 0 : null,
            maxX: box.maxX,
            maxY: box.maxY,
            maxZ: type.is3D ? box.maxZ ?? 0 : null,
            maxM: type.isMeasured ? box.maxM ?? 0 : null,
          );
        }
      }
    } else if (box is Iterable<num>) {
      return buildBox(box, to: to, type: type);
    }
    throw invalidCoordinates;
  }

  /// Builds a bounding box of [R] from [coords] starting from [offset].
  ///
  /// A bounding box instance is created using the factory function [to].
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
  static R buildBox<R extends Box>(
    Iterable<num> coords, {
    required CreateBox<R> to,
    int offset = 0,
    Coords? type,
  }) {
    if (coords is List<num>) {
      final len = coords.length - offset;
      final coordsType = type ?? Coords.fromDimension(math.min(4, len ~/ 2));
      final dim = coordsType.coordinateDimension;
      if (len < 2 * dim) {
        throw invalidCoordinates;
      }
      final mIndex = coordsType.indexForM;
      return to.call(
        minX: coords[offset].toDouble(),
        minY: coords[offset + 1].toDouble(),
        minZ: coordsType.is3D ? coords[offset + 2].toDouble() : null,
        minM: mIndex != null ? coords[offset + mIndex].toDouble() : null,
        maxX: coords[offset + dim].toDouble(),
        maxY: coords[offset + dim + 1].toDouble(),
        maxZ: coordsType.is3D ? coords[offset + dim + 2].toDouble() : null,
        maxM: mIndex != null ? coords[offset + dim + mIndex].toDouble() : null,
      );
    } else {
      // resolve iterator for source coordinates
      final Iterator<num> iter;
      if (offset == 0) {
        iter = coords.iterator;
      } else if (coords.length >= offset + 4) {
        iter = coords.skip(offset).iterator;
      } else {
        throw invalidCoordinates;
      }

      // must contain at least four numbers
      if (!iter.moveNext()) throw invalidCoordinates;
      final c0 = iter.current;
      if (!iter.moveNext()) throw invalidCoordinates;
      final c1 = iter.current;
      if (!iter.moveNext()) throw invalidCoordinates;
      final c2 = iter.current;
      if (!iter.moveNext()) throw invalidCoordinates;
      final c3 = iter.current;

      // rest 4 are optional, get first of them
      final c4 = iter.moveNext() ? iter.current : null;

      // if xy coordinates (4 items), then return already now
      if (type == Coords.xy || (c4 == null && type == null)) {
        return to.call(
          minX: c0.toDouble(),
          minY: c1.toDouble(),
          maxX: c2.toDouble(),
          maxY: c3.toDouble(),
        );
      }

      // then get also last 3 of the optional
      final c5 = iter.moveNext() ? iter.current : null;
      final c6 = iter.moveNext() ? iter.current : null;
      final c7 = iter.moveNext() ? iter.current : null;

      // resolve coordinate type
      final Coords coordType;
      if (type != null) {
        // explicitely
        coordType = type;
      } else {
        // implicitely
        if (c4 != null && c5 != null) {
          coordType = c6 != null && c7 != null ? Coords.xyzm : Coords.xyz;
        } else {
          coordType = Coords.xy;
        }
      }

      // create bounding box depending on coordinate type
      switch (coordType) {
        case Coords.xy:
          if (c4 == null) {
            return to.call(
              minX: c0.toDouble(),
              minY: c1.toDouble(),
              maxX: c2.toDouble(),
              maxY: c3.toDouble(),
            );
          }
          break;
        case Coords.xyz:
          if (c4 != null && c5 != null && c6 == null) {
            return to.call(
              minX: c0.toDouble(),
              minY: c1.toDouble(),
              minZ: c2.toDouble(),
              maxX: c3.toDouble(),
              maxY: c4.toDouble(),
              maxZ: c5.toDouble(),
            );
          }
          break;
        case Coords.xym:
          if (c4 != null && c5 != null && c6 == null) {
            return to.call(
              minX: c0.toDouble(),
              minY: c1.toDouble(),
              minM: c2.toDouble(),
              maxX: c3.toDouble(),
              maxY: c4.toDouble(),
              maxM: c5.toDouble(),
            );
          }
          break;
        case Coords.xyzm:
          if (c4 != null && c5 != null && c6 != null && c7 != null) {
            return to.call(
              minX: c0.toDouble(),
              minY: c1.toDouble(),
              minZ: c2.toDouble(),
              minM: c3.toDouble(),
              maxX: c4.toDouble(),
              maxY: c5.toDouble(),
              maxZ: c6.toDouble(),
              maxM: c7.toDouble(),
            );
          }
          break;
      }
      throw invalidCoordinates;
    }
  }

  /// Creates a bounding box of [R] from [text].
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// A bounding box instance is created using the factory function [to].
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
  static R parseBox<R extends Box>(
    String text, {
    required CreateBox<R> to,
    Pattern? delimiter = ',',
    Coords? type,
  }) {
    final coords = parseDoubleValues(text, delimiter: delimiter);
    return buildBox(coords, to: to, type: type);
  }

  /// Returns an aligned 2D position relative to [box].
  static R createAligned2D<R extends Position>(
    Box box,
    CreatePosition<R> factory, {
    Aligned align = Aligned.center,
  }) =>
      factory.call(
        x: box.minX + box.width * (1.0 + align.x) / 2.0,
        y: box.minY + box.height * (1.0 + align.y) / 2.0,
      );

  /// Returns all distinct (in 2D) corners for this axis aligned bounding box.
  static Iterable<R> createCorners2D<R extends Position>(
    Box box,
    CreatePosition<R> factory,
  ) {
    final min = box.min;
    final max = box.max;
    if (min == max) {
      return [
        min.copyTo(factory),
      ];
    } else if (min.x == max.x || min.y == max.y) {
      return [
        min.copyTo(factory),
        max.copyTo(factory),
      ];
    } else {
      final midZ = box.is3D ? 0.5 * min.z + 0.5 * max.z : null;
      final midM = box.isMeasured ? 0.5 * min.m + 0.5 * max.m : null;
      return [
        min.copyTo(factory),
        factory(x: max.x, y: min.y, z: midZ, m: midM),
        max.copyTo(factory),
        factory(x: min.x, y: max.y, z: midZ, m: midM),
      ];
    }
  }

  /// A minimum bounding box created by [factory], calculated from [positions].
  ///
  /// Throws FormatException if cannot create (ie. [positions] is empty).
  static R createBoxFrom<R extends Box>(
    Iterable<Position> positions,
    CreateBox<R> factory,
  ) {
    // calculate mininum and maximum coordinates
    double? minX, minY, minZ, minM;
    double? maxX, maxY, maxZ, maxM;
    var isFirst = true;
    for (final cp in positions) {
      if (isFirst) {
        minX = cp.x;
        minY = cp.y;
        minZ = cp.optZ;
        minM = cp.optM;
        maxX = cp.x;
        maxY = cp.y;
        maxZ = cp.optZ;
        maxM = cp.optM;
      } else {
        minX = math.min(minX!, cp.x);
        minY = math.min(minY!, cp.y);
        minZ = cp.is3D && minZ != null ? math.min(minZ, cp.z) : null;
        minM = cp.isMeasured && minM != null ? math.min(minM, cp.m) : null;
        maxX = math.max(maxX!, cp.x);
        maxY = math.max(maxY!, cp.y);
        maxZ = cp.is3D && maxZ != null ? math.max(maxZ, cp.z) : null;
        maxM = cp.isMeasured && maxM != null ? math.max(maxM, cp.m) : null;
      }
      isFirst = false;
    }

    if (isFirst) {
      throw const FormatException('Positions should not be empty.');
    }

    // create a new bounding box
    return factory.call(
      minX: minX!,
      minY: minY!,
      minZ: minZ,
      minM: minM,
      maxX: maxX!,
      maxY: maxY!,
      maxZ: maxZ,
      maxM: maxM,
    );
  }

  /// Coordinate values of [box] as a double list of 4, 6 or 8 items.
  static List<double> getDoubleList(Box box) {
    return getDoubleListFrom(
      minX: box.minX,
      minY: box.minY,
      minZ: box.minZ,
      minM: box.minM,
      maxX: box.maxX,
      maxY: box.maxY,
      maxZ: box.maxZ,
      maxM: box.maxM,
    );
  }

  /// Coordinate values of Box as a double list of 4, 6 or 8 items.
  static List<double> getDoubleListFrom({
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
    return list;
  }

  /// Writes coordinate values of [box] to [buffer] separated by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// Set [swapXY] to true to print y (or latitude) before x (or longitude).
  ///
  /// A sample with default parameters (for a 2D bounding box):
  /// `10.1,10.1,20.2,20.2`
  static void writeValues(
    Box box,
    StringSink buffer, {
    String delimiter = ',',
    int? decimals,
    bool swapXY = false,
  }) {
    Position.writeValues(
      box.min,
      buffer,
      delimiter: delimiter,
      decimals: decimals,
      swapXY: swapXY,
    );
    buffer.write(delimiter);
    Position.writeValues(
      box.max,
      buffer,
      delimiter: delimiter,
      decimals: decimals,
      swapXY: swapXY,
    );
  }

  /// True if [box1] and [box2] equals by testing all coordinate values.
  static bool testEquals(Box box1, Box box2) =>
      box1.minX == box2.minX &&
      box1.minY == box2.minY &&
      box1.minZ == box2.minZ &&
      box1.minM == box2.minM &&
      box1.maxX == box2.maxX &&
      box1.maxY == box2.maxY &&
      box1.maxZ == box2.maxZ &&
      box1.maxM == box2.maxM;

  /// The hash code for [box].
  static int hash(Box box) => Object.hash(
        box.minX,
        box.minY,
        box.minZ,
        box.minM,
        box.maxX,
        box.maxY,
        box.maxZ,
        box.maxM,
      );

  /// True if positions [box1] and [box2] equals by testing 2D coordinates only.
  static bool testEquals2D(
    Box box1,
    Box box2, {
    double toleranceHoriz = defaultEpsilon,
  }) {
    assertTolerance(toleranceHoriz);
    return (box1.minX - box2.minX).abs() <= toleranceHoriz &&
        (box1.minY - box2.minY).abs() <= toleranceHoriz &&
        (box1.maxX - box2.maxX).abs() <= toleranceHoriz &&
        (box1.maxY - box2.maxY).abs() <= toleranceHoriz;
  }

  /// True if positions [box1] and [box2] equals by testing 3D coordinates only.
  static bool testEquals3D(
    Box box1,
    Box box2, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  }) {
    assertTolerance(toleranceVert);
    if (!Box.testEquals2D(box1, box2, toleranceHoriz: toleranceHoriz)) {
      return false;
    }
    if (!box1.is3D || !box1.is3D) {
      return false;
    }

    final minZ1 = box1.minZ;
    final maxZ1 = box1.maxZ;
    final minZ2 = box2.minZ;
    final maxZ2 = box2.maxZ;
    return minZ1 != null &&
        maxZ1 != null &&
        minZ2 != null &&
        maxZ2 != null &&
        (minZ1 - minZ2).abs() <= toleranceVert &&
        (maxZ1 - maxZ2).abs() <= toleranceVert;
  }

  /// Returns true if [box1] and [box2] intersects in 2D.
  static bool testIntersects2D(Box box1, Box box2) {
    return !(box1.minX > box2.maxX ||
        box1.maxX < box2.minX ||
        box1.minY > box2.maxY ||
        box1.maxY < box2.minY);
  }

  /// Returns true if [box1] and [box2] intersects.
  static bool testIntersects(Box box1, Box box2) {
    if (box1.minX > box2.maxX ||
        box1.maxX < box2.minX ||
        box1.minY > box2.maxY ||
        box1.maxY < box2.minY) {
      return false;
    }
    if (box1.is3D != box2.is3D || box1.isMeasured != box2.isMeasured) {
      return false;
    }
    if (box1.is3D && (box1.minZ! > box2.maxZ! || box1.maxZ! < box2.minZ!)) {
      return false;
    }
    if (box1.isMeasured &&
        (box1.minM! > box2.maxM! || box1.maxM! < box2.minM!)) {
      return false;
    }
    return true;
  }

  /// Returns true if [box] intesects with [point] in 2D.
  static bool testIntersectsPoint2D(Box box, Position point) {
    return !(box.minX > point.x ||
        box.maxX < point.x ||
        box.minY > point.y ||
        box.maxY < point.y);
  }

  /// Returns true if [box] intesects with [point].
  static bool testIntersectsPoint(Box box, Position point) {
    if (box.minX > point.x ||
        box.maxX < point.x ||
        box.minY > point.y ||
        box.maxY < point.y) {
      return false;
    }
    if (box.is3D != point.is3D || box.isMeasured != point.isMeasured) {
      return false;
    }
    if (box.is3D && (box.minZ! > point.z || box.maxZ! < point.z)) {
      return false;
    }
    if (box.isMeasured && (box.minM! > point.m || box.maxM! < point.m)) {
      return false;
    }
    return true;
  }
}
