// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import '/src/base/coordinates.dart';

// Some basic transformation functions (like translate, scale, rotate).
// Not meant to be complete set of transformation.

/// Returns a function to translate positions by delta values of each axis.
///
/// Set optional [dx], [dy], [dz] and [dm] values for translating on a
/// corresponding axis.
///
/// If a point to be translated do not have an axis even if a translation delta
/// for that axis is given, then such delta is ignored.
TransformPosition translatePoint<C extends num>({
  C? dx,
  C? dy,
  C? dz,
  C? dm,
}) =>
    <T extends Position>(T source) {
      final dim = source.coordinateDimension;
      if (dim == 2) {
        // point is (X, Y)
        return source.copyWith(
          x: dx != null ? source[0] + dx : null,
          y: dy != null ? source[1] + dy : null,
        ) as T;
      } else {
        // point could be (X, Y, Z), (X, Y, M) or (X, Y, Z, M)
        return source.copyWith(
          x: dx != null ? source[0] + dx : null,
          y: dy != null ? source[1] + dy : null,
          z: dz != null && source.is3D ? source[2] + dz : null,
          m: dm != null && source.isMeasured ? source.m + dm : null,
        ) as T;
      }
    };

/// Returns a function to scale positions by scale factors for each axis.
///
/// Set optional [sx], [sy], [sz] and [sm] scale factors for scaling on a
/// corresponding axis.
///
/// If a point to be scaled do not have an axis even if a scale factor
/// for that axis is given, then such factor is ignored.
TransformPosition scalePoint<C extends num>({
  C? sx,
  C? sy,
  C? sz,
  C? sm,
}) =>
    <T extends Position>(T source) {
      final dim = source.coordinateDimension;
      if (dim == 2) {
        // point is (X, Y)
        return source.copyWith(
          x: sx != null ? sx * source[0] : null,
          y: sy != null ? sy * source[1] : null,
        ) as T;
      } else {
        // point could be (X, Y, Z), (X, Y, M) or (X, Y, Z, M)
        return source.copyWith(
          x: sx != null ? sx * source[0] : null,
          y: sy != null ? sy * source[1] : null,
          z: sz != null && source.is3D ? sz * source[2] : null,
          m: sm != null && source.isMeasured ? sm * source.m : null,
        ) as T;
      }
    };

/// Returns a function to scale positions by the [scale] factor.
TransformPosition scalePointBy<C extends num>(C scale) =>
    <T extends Position>(T source) {
      final dim = source.coordinateDimension;
      if (dim == 2) {
        // point is (X, Y)
        return source.copyWith(
          x: scale * source[0],
          y: scale * source[1],
        ) as T;
      } else {
        // point could be (X, Y, Z), (X, Y, M) or (X, Y, Z, M)
        return source.copyWith(
          x: scale * source[0],
          y: scale * source[1],
          z: source.is3D ? scale * source[2] : null,
          m: source.isMeasured ? scale * source.m : null,
        ) as T;
      }
    };

/// Returns a function to rotate positions by the [radians] around the origin.
///
/// If both [cx] and [cy] are given then rotate points around this pivot point.
TransformPosition rotatePoint2D(num radians, {num? cx, num? cy}) =>
    <T extends Position>(T source) {
      final s = math.sin(radians);
      final c = math.cos(radians);

      var x = source[0];
      var y = source[1];

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
