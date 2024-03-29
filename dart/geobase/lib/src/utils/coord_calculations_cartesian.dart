// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import 'package:meta/meta.dart';

import '/src/common/functions/position_functions.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';

/// Returns a midpoint between this and [destination] positions calculated in
/// the cartesian coordinate reference system.
@internal
R cartesianMidPointTo<R extends Position>(
  R source,
  Position destination, {
  required CreatePosition<R> to,
}) {
  if (source == destination) return source;

  final hasZ = source.is3D && destination.is3D;
  final hasM = source.isMeasured && destination.isMeasured;
  return to.call(
    x: 0.5 * source.x + 0.5 * destination.x,
    y: 0.5 * source.y + 0.5 * destination.y,
    z: hasZ ? 0.5 * source.z + 0.5 * destination.z : null,
    m: hasM ? 0.5 * source.m + 0.5 * destination.m : null,
  );
}

/// Returns an intermediate point at the given [fraction] between this and
/// [destination] positions calculated in the cartesian coordinate reference
/// system.
///
/// Parameters:
/// * [fraction]: 0.0 = this position, 1.0 = destination
@internal
R cartesianIntermediatePointTo<R extends Position>(
  R source,
  Position destination, {
  required double fraction,
  required CreatePosition<R> to,
}) {
  if (source == destination || fraction == 0.0) return source;
  if (fraction == 1.0 && destination is R) return destination;

  final hasZ = source.is3D && destination.is3D;
  final hasM = source.isMeasured && destination.isMeasured;
  return to.call(
    x: source.x + fraction * (destination.x - source.x),
    y: source.y + fraction * (destination.y - source.y),
    z: hasZ ? source.z + fraction * (destination.z - source.z) : null,
    m: hasM ? source.m + fraction * (destination.m - source.m) : null,
  );
}

/// Returns a destination point located at the given [distance] from this to
/// the direction of [bearing] calculated in a cartesian 2D plane.
///
/// The bearing is measured in degrees (0°..360°) with 0° pointing to the
/// positive Y-axis ("north"), 90° to the positive X-axis ("east"), 180° to
/// the negative Y-axis ("south"), and 270° to the negative X-axis ("west").
@internal
R cartesianDestinationPoint2D<R extends Position>(
  R source, {
  required double distance,
  required double bearing,
  required CreatePosition<R> to,
}) {
  if (distance == 0.0) return source;

  final bear = bearing % 360.0;
  final double angleDeg;
  if (bear < 270.0) {
    angleDeg = 90.0 - bear;
  } else {
    angleDeg = 450.0 - bear;
  }
  final angleRad = angleDeg.toRadians();

  return to.call(
    x: source.x + distance * math.cos(angleRad),
    y: source.y + distance * math.sin(angleRad),
  );
}

/// Returns a position with all coordinate values summed from [p1] and [p2].
@internal
R cartesianPositionSum<R extends Position>(
  Position p1,
  Position p2, {
  required CreatePosition<R> to,
}) {
  final hasZ = p1.is3D && p2.is3D;
  final hasM = p1.isMeasured && p2.isMeasured;
  return to.call(
    x: p1.x + p2.x,
    y: p1.y + p2.y,
    z: hasZ ? p1.z + p2.z : null,
    m: hasM ? p1.m + p2.m : null,
  );
}

/// Returns a position with coordinate values of [p1] subtracted with values of
/// [p2].
@internal
R cartesianPositionSubtract<R extends Position>(
  Position p1,
  Position p2, {
  required CreatePosition<R> to,
}) {
  final hasZ = p1.is3D && p2.is3D;
  final hasM = p1.isMeasured && p2.isMeasured;
  return to.call(
    x: p1.x - p2.x,
    y: p1.y - p2.y,
    z: hasZ ? p1.z - p2.z : null,
    m: hasM ? p1.m - p2.m : null,
  );
}

/// Returns a position with coordinate values of [position] scaled by [factor].
@internal
R cartesianPositionScale<R extends Position>(
  Position position, {
  required double factor,
  required CreatePosition<R> to,
}) {
  final hasZ = position.is3D;
  final hasM = position.isMeasured;
  return to.call(
    x: factor * position.x,
    y: factor * position.y,
    z: hasZ ? factor * position.z : null,
    m: hasM ? factor * position.m : null,
  );
}

/// Returns a position with coordinate values of [position] divided by values of
/// [divisor].
@internal
R cartesianPositionDivision<R extends Position>(
  Position position, {
  required Position divisor,
  required CreatePosition<R> to,
}) {
  final hasZ = position.is3D && divisor.is3D;
  final hasM = position.isMeasured && divisor.isMeasured;
  return to.call(
    x: position.x / divisor.x,
    y: position.y / divisor.y,
    z: hasZ ? position.z / divisor.z : null,
    m: hasM ? position.m / divisor.m : null,
  );
}

/// Returns a position with coordinate values of [position] applied with modulo
/// operator `%` by values of [divisor].
@internal
R cartesianPositionModulo<R extends Position>(
  Position position, {
  required Position divisor,
  required CreatePosition<R> to,
}) {
  final hasZ = position.is3D && divisor.is3D;
  final hasM = position.isMeasured && divisor.isMeasured;
  return to.call(
    x: position.x % divisor.x,
    y: position.y % divisor.y,
    z: hasZ ? position.z % divisor.z : null,
    m: hasM ? position.m % divisor.m : null,
  );
}

/// Returns a position with coordinate values of [position] negated.
@internal
R cartesianPositionNegate<R extends Position>(
  Position position, {
  required CreatePosition<R> to,
}) {
  final hasZ = position.is3D;
  final hasM = position.isMeasured;
  return to.call(
    x: -position.x,
    y: -position.y,
    z: hasZ ? -position.z : null,
    m: hasM ? -position.m : null,
  );
}

/// Returns a bounding box with min and max coordinate values of [box] summed
/// with coordinate values of [addend].
@internal
R cartesianBoxSum<R extends Box>(
  Box box,
  Position addend, {
  required CreateBox<R> to,
}) {
  final hasZ = box.is3D && addend.is3D;
  final hasM = box.isMeasured && addend.isMeasured;
  return to.call(
    minX: box.minX + addend.x,
    minY: box.minY + addend.y,
    minZ: hasZ ? (box.minZ ?? 0.0) + addend.z : null,
    minM: hasM ? (box.minM ?? 0.0) + addend.m : null,
    maxX: box.maxX + addend.x,
    maxY: box.maxY + addend.y,
    maxZ: hasZ ? (box.maxZ ?? 0.0) + addend.z : null,
    maxM: hasM ? (box.maxM ?? 0.0) + addend.m : null,
  );
}

/// Returns a bounding box with min and max coordinate values of [box] summed
/// with coordinate values of [subtract].
@internal
R cartesianBoxSubtract<R extends Box>(
  Box box,
  Position subtract, {
  required CreateBox<R> to,
}) {
  final hasZ = box.is3D && subtract.is3D;
  final hasM = box.isMeasured && subtract.isMeasured;
  return to.call(
    minX: box.minX - subtract.x,
    minY: box.minY - subtract.y,
    minZ: hasZ ? (box.minZ ?? 0.0) - subtract.z : null,
    minM: hasM ? (box.minM ?? 0.0) - subtract.m : null,
    maxX: box.maxX - subtract.x,
    maxY: box.maxY - subtract.y,
    maxZ: hasZ ? (box.maxZ ?? 0.0) - subtract.z : null,
    maxM: hasM ? (box.maxM ?? 0.0) - subtract.m : null,
  );
}

/// Returns a bounding box with coordinate values of [box] scaled by [factor].
@internal
R cartesianBoxScale<R extends Box>(
  Box box, {
  required double factor,
  required CreateBox<R> to,
}) {
  final hasZ = box.is3D;
  final hasM = box.isMeasured;
  return to.call(
    minX: factor * box.minX,
    minY: factor * box.minY,
    minZ: hasZ ? factor * (box.minZ ?? 0.0) : null,
    minM: hasM ? factor * (box.minM ?? 0.0) : null,
    maxX: factor * box.maxX,
    maxY: factor * box.maxY,
    maxZ: hasZ ? factor * (box.maxZ ?? 0.0) : null,
    maxM: hasM ? factor * (box.maxM ?? 0.0) : null,
  );
}

/// Returns a bounding box with coordinate values of [box] negated.
@internal
R cartesianBoxNegate<R extends Box>(
  Box box, {
  required CreateBox<R> to,
}) {
  final hasZ = box.is3D;
  final hasM = box.isMeasured;
  return to.call(
    minX: -box.minX,
    minY: -box.minY,
    minZ: hasZ ? -(box.minZ ?? 0.0) : null,
    minM: hasM ? -(box.minM ?? 0.0) : null,
    maxX: -box.maxX,
    maxY: -box.maxY,
    maxZ: hasZ ? -(box.maxZ ?? 0.0) : null,
    maxM: hasM ? -(box.maxM ?? 0.0) : null,
  );
}
