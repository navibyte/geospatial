// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// A function to transform the [source] point of [T] to a point of [T].
///
/// Target points of [T] are created using [source] as a point factory.
typedef TransformPoint = T Function<T extends Point>(T source);

/// A function to project the [source] point of [T] to a point of [R].
///
/// When [to] is provided, then target points of [R] are created using that
/// as a point factory. Otherwise a projection function uses it's own factory.
///
/// Note that a function could implement for example a map projection from
/// geographical points to projected cartesian points, or an inverse
/// projection (or an "unprojection") from projected cartesian points to
/// geographical points. Both are called here "project point" functions.
typedef ProjectPoint<T extends Point, R extends Point> = R Function(
  T source, {
  PointFactory<R>? to,
});

// -----------------------------------------------------------------------------
// Some basic transformation functions (like translate, scale, rotate).
// Not meant to be complete set of transformation.
//
// Geospatial projections between coordinate reference systems on other
// packages.

/// Returns a function to translate points by delta values of each axis.
///
/// Set optional [dx], [dy], [dz] and [dm] values for translating on a
/// corresponding axis.
///
/// If a point to be translated do not have an axis even if a translation delta
/// for that axis is given, then such delta is ignored.
TransformPoint translatePoint<C extends num>({
  C? dx,
  C? dy,
  C? dz,
  C? dm,
}) =>
    <T extends Point>(T source) {
      final dim = source.coordinateDimension;
      if (dim == 2) {
        // point is (X, Y)
        return source.copyWith(
          x: dx != null ? source.x + dx : null,
          y: dy != null ? source.y + dy : null,
        ) as T;
      } else {
        // point could be (X, Y, Z), (X, Y, M) or (X, Y, Z, M)
        return source.copyWith(
          x: dx != null ? source.x + dx : null,
          y: dy != null ? source.y + dy : null,
          z: dz != null && source.is3D ? source.z + dz : null,
          m: dm != null && source.hasM ? source.m + dm : null,
        ) as T;
      }
    };

/// Returns a function to scale points by scale factors for each axis.
///
/// Set optional [sx], [sy], [sz] and [sm] scale factors for scaling on a
/// corresponding axis.
///
/// If a point to be scaled do not have an axis even if a scale factor
/// for that axis is given, then such factor is ignored.
TransformPoint scalePoint<C extends num>({
  C? sx,
  C? sy,
  C? sz,
  C? sm,
}) =>
    <T extends Point>(T source) {
      final dim = source.coordinateDimension;
      if (dim == 2) {
        // point is (X, Y)
        return source.copyWith(
          x: sx != null ? sx * source.x : null,
          y: sy != null ? sy * source.y : null,
        ) as T;
      } else {
        // point could be (X, Y, Z), (X, Y, M) or (X, Y, Z, M)
        return source.copyWith(
          x: sx != null ? sx * source.x : null,
          y: sy != null ? sy * source.y : null,
          z: sz != null && source.is3D ? sz * source.z : null,
          m: sm != null && source.hasM ? sm * source.m : null,
        ) as T;
      }
    };

/// Returns a function to scale points by the [scale] factor.
TransformPoint scalePointBy<C extends num>(C scale) =>
    <T extends Point>(T source) {
      final dim = source.coordinateDimension;
      if (dim == 2) {
        // point is (X, Y)
        return source.copyWith(
          x: scale * source.x,
          y: scale * source.y,
        ) as T;
      } else {
        // point could be (X, Y, Z), (X, Y, M) or (X, Y, Z, M)
        return source.copyWith(
          x: scale * source.x,
          y: scale * source.y,
          z: source.is3D ? scale * source.z : null,
          m: source.hasM ? scale * source.m : null,
        ) as T;
      }
    };

/// Returns a function to rotate points by the [radians] around the origin.
///
/// If both [cx] and [cy] are given then rotate points around this pivot point.
TransformPoint rotatePoint2D(num radians, {num? cx, num? cy}) =>
    <T extends Point>(T source) {
      final s = math.sin(radians);
      final c = math.cos(radians);

      var x = source.x;
      var y = source.y;

      // if has pivot point, then move origin
      if (cx != null && cy != null) {
        x -= cx;
        y -= cy;
      }

      // rotate point
      final xnew = x * c - y * s;
      final ynew = x * s + y * c;

      // return rotated point
      if (cx != null && cy != null) {
        return source.copyWith(
          x: xnew + cx,
          y: ynew + cy,
        ) as T;
      } else {
        return source.copyWith(x: xnew, y: ynew) as T;
      }
    };

// todo other basic transformations
