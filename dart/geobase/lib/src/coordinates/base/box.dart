// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import '/src/utils/format_validation.dart';
import '/src/utils/num.dart';
import '/src/utils/tolerance.dart';

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
  required num minX,
  required num minY,
  num? minZ,
  num? minM,
  required num maxX,
  required num maxY,
  num? maxZ,
  num? maxM,
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
/// minM, east, north, maxElev and maxM coordinates)
abstract class Box extends Positionable {
  /// Default `const` constructor to allow extending this abstract class.
  const Box();

  /// The minimum x (or west) coordinate.
  ///
  /// For geographic coordinates minX represents *west* longitude.
  num get minX;

  /// The minimum y (or south) coordinate.
  ///
  /// For geographic coordinates minY represents *south* latitude.
  num get minY;

  /// The minimum z coordinate optionally. Returns null if not available.
  ///
  /// For geographic coordinates minZ represents minimum elevation or altitude.
  ///
  /// You can also use [is3D] to check whether z coordinate available.
  num? get minZ;

  /// The minimum m coordinate optionally. Returns null if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available.
  num? get minM;

  /// The maximum x (or east) coordinate.
  ///
  /// For geographic coordinates maxX represents *east* longitude.
  num get maxX;

  /// The maximum y (or north) coordinate.
  ///
  /// For geographic coordinates maxY represents *north* latitude.
  num get maxY;

  /// The maximum z coordinate optionally. Returns null if not available.
  ///
  /// For geographic coordinates maxZ represents maximum elevation or altitude.
  ///
  /// You can also use [is3D] to check whether z coordinate available.
  num? get maxZ;

  /// The maximum m coordinate optionally. Returns null if not available.
  ///
  /// You can also use [isMeasured] to check whether m coordinate is available.
  num? get maxM;

  /// The minimum position (or west-south) of this bounding box.
  Position get min;

  /// The maximum position (or east-north) of this bounding box.
  Position get max;

  /// Returns all distinct (in 2D) corners for this axis aligned bounding box.
  ///
  /// May return 1 (when `min == max`), 2 (when either or both 2D coordinates
  /// equals between min and max) or 4 positions (otherwise).
  Iterable<Position> get corners2D;

  /// True if this box equals with [other] by testing 2D coordinates only.
  ///
  /// If [toleranceHoriz] is given, then differences on 2D coordinate values
  /// (ie. x and y, or lon and lat) between this and [other] must be within
  /// tolerance. Otherwise value must be exactly same.
  ///
  /// Tolerance values must be null or positive (>= 0).
  bool equals2D(Box other, {num? toleranceHoriz}) =>
      Box.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

  /// True if this box equals with [other] by testing 3D coordinates only.
  ///
  /// Returns false if this or [other] is not a 3D box.
  ///
  /// If [toleranceHoriz] is given, then differences on 2D coordinate values
  /// (ie. x and y, or lon and lat) between this and [other] must be within
  /// tolerance. Otherwise value must be exactly same.
  ///
  /// The tolerance for vertical coordinate values (ie. z or elev) is given by
  /// an optional [toleranceVert] value.
  ///
  /// Tolerance values must be null or positive (>= 0).
  bool equals3D(
    Box other, {
    num? toleranceHoriz,
    num? toleranceVert,
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

  // ---------------------------------------------------------------------------
  // Static methods with default logic, used by Box, ProjBox and GeoBox.

  /// Creates a bounding box of [R] from [box] (of [R] or `Iterable<num>`).
  ///
  /// If [box] is [R] already, then it's returned.
  ///
  /// If [box] is `Iterable<num>`, then a bounding box instance is created using
  /// the factory function [to]. Allowed coordinate value combinations:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// Otherwise throws `FormatException`.
  static R createFromObject<R extends Box>(
    Object box, {
    required CreateBox<R> to,
  }) {
    if (box is R) {
      return box;
    } else if (box is Iterable<num>) {
      return createFromCoords(box, to: to);
    }
    throw illegalCoordinates;
  }

  /// Creates a bounding box of [R] from [coords] starting from [offset].
  ///
  /// A valid [coords] contains coordinate values for one of these combinations:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// A bounding box instance is created using the factory function [to].
  static R createFromCoords<R extends Box>(
    Iterable<num> coords, {
    required CreateBox<R> to,
    int offset = 0,
  }) {
    final len = coords.length - offset;
    if (len < 4) {
      throw const FormatException('Coords must contain at least four items');
    }
    if (len >= 8) {
      return to.call(
        minX: coords.elementAt(offset),
        minY: coords.elementAt(offset + 1),
        minZ: coords.elementAt(offset + 2),
        minM: coords.elementAt(offset + 3),
        maxX: coords.elementAt(offset + 4),
        maxY: coords.elementAt(offset + 5),
        maxZ: coords.elementAt(offset + 6),
        maxM: coords.elementAt(offset + 7),
      );
    } else if (len >= 6) {
      return to.call(
        minX: coords.elementAt(offset),
        minY: coords.elementAt(offset + 1),
        minZ: coords.elementAt(offset + 2),
        maxX: coords.elementAt(offset + 3),
        maxY: coords.elementAt(offset + 4),
        maxZ: coords.elementAt(offset + 5),
      );
    } else {
      return to.call(
        minX: coords.elementAt(offset),
        minY: coords.elementAt(offset + 1),
        maxX: coords.elementAt(offset + 2),
        maxY: coords.elementAt(offset + 3),
      );
    }
  }

  /// Creates a bounding box of [R] from [text].
  ///
  /// A valid [text] contains coordinate values for one of these combinations:
  /// - minX, minY, maxX, maxY
  /// - minX, minY, minZ, maxX, maxY, maxZ
  /// - minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// A bounding box instance is created using the factory function [to].
  static R createFromText<R extends Box>(
    String text, {
    required CreateBox<R> to,
    Pattern? delimiter = ',',
  }) {
    final coords = parseNullableNumValuesFromText(text, delimiter: delimiter);
    final len = coords.length;
    if (len < 4) {
      throw const FormatException('Coords must contain at least four items');
    }
    if (len >= 8) {
      final minX = coords.elementAt(0);
      final minY = coords.elementAt(1);
      final maxX = coords.elementAt(4);
      final maxY = coords.elementAt(5);
      if (minX == null || minY == null || maxX == null || maxY == null) {
        throw const FormatException('minX, minY, maxX and maxY are required.');
      }
      return to.call(
        minX: minX,
        minY: minY,
        minZ: coords.elementAt(2),
        minM: coords.elementAt(3),
        maxX: maxX,
        maxY: maxY,
        maxZ: coords.elementAt(6),
        maxM: coords.elementAt(7),
      );
    } else if (len >= 6) {
      final minX = coords.elementAt(0);
      final minY = coords.elementAt(1);
      final maxX = coords.elementAt(3);
      final maxY = coords.elementAt(4);
      if (minX == null || minY == null || maxX == null || maxY == null) {
        throw const FormatException('minX, minY, maxX and maxY are required.');
      }
      return to.call(
        minX: minX,
        minY: minY,
        minZ: coords.elementAt(2),
        maxX: maxX,
        maxY: maxY,
        maxZ: coords.elementAt(5),
      );
    } else {
      final minX = coords.elementAt(0);
      final minY = coords.elementAt(1);
      final maxX = coords.elementAt(2);
      final maxY = coords.elementAt(3);
      if (minX == null || minY == null || maxX == null || maxY == null) {
        throw const FormatException('minX, minY, maxX and maxY are required.');
      }
      return to.call(
        minX: minX,
        minY: minY,
        maxX: maxX,
        maxY: maxY,
      );
    }
  }

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
    num? minX, minY, minZ, minM;
    num? maxX, maxY, maxZ, maxM;
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
    num? toleranceHoriz,
  }) {
    assertTolerance(toleranceHoriz);
    return toleranceHoriz != null
        ? (box1.minX - box2.minX).abs() <= toleranceHoriz &&
            (box1.minY - box2.minY).abs() <= toleranceHoriz &&
            (box1.maxX - box2.maxX).abs() <= toleranceHoriz &&
            (box1.maxY - box2.maxY).abs() <= toleranceHoriz
        : box1.minX == box2.minX &&
            box1.minY == box2.minY &&
            box1.maxX == box2.maxX &&
            box1.maxY == box2.maxY;
  }

  /// True if positions [box1] and [box2] equals by testing 3D coordinates only.
  static bool testEquals3D(
    Box box1,
    Box box2, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) {
    assertTolerance(toleranceVert);
    if (!Box.testEquals2D(box1, box2, toleranceHoriz: toleranceHoriz)) {
      return false;
    }
    if (!box1.is3D || !box1.is3D) {
      return false;
    }
    if (toleranceVert != null) {
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
    } else {
      return box1.minZ == box2.minZ && box1.maxZ == box2.maxZ;
    }
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
