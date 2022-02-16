// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import 'package:geobase/geobase.dart';

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
      final pos = source.asPosition;
      final dim = pos.coordinateDimension;
      if (dim == 2) {
        // point is (X, Y)
        return source.copyWith(
          x: dx != null ? pos.x + dx : null,
          y: dy != null ? pos.y + dy : null,
        ) as T;
      } else {
        // point could be (X, Y, Z), (X, Y, M) or (X, Y, Z, M)
        return source.copyWith(
          x: dx != null ? pos.x + dx : null,
          y: dy != null ? pos.y + dy : null,
          z: dz != null && pos.is3D ? pos.z + dz : null,
          m: dm != null && pos.isMeasured ? pos.m + dm : null,
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
      final pos = source.asPosition;
      final dim = pos.coordinateDimension;
      if (dim == 2) {
        // point is (X, Y)
        return source.copyWith(
          x: sx != null ? sx * pos.x : null,
          y: sy != null ? sy * pos.y : null,
        ) as T;
      } else {
        // point could be (X, Y, Z), (X, Y, M) or (X, Y, Z, M)
        return source.copyWith(
          x: sx != null ? sx * pos.x : null,
          y: sy != null ? sy * pos.y : null,
          z: sz != null && pos.is3D ? sz * pos.z : null,
          m: sm != null && pos.isMeasured ? sm * pos.m : null,
        ) as T;
      }
    };

/// Returns a function to scale positions by the [scale] factor.
TransformPosition scalePointBy<C extends num>(C scale) =>
    <T extends Position>(T source) {
      final pos = source.asPosition;
      final dim = pos.coordinateDimension;
      if (dim == 2) {
        // point is (X, Y)
        return source.copyWith(
          x: scale * pos.x,
          y: scale * pos.y,
        ) as T;
      } else {
        // point could be (X, Y, Z), (X, Y, M) or (X, Y, Z, M)
        return source.copyWith(
          x: scale * pos.x,
          y: scale * pos.y,
          z: pos.is3D ? scale * pos.z : null,
          m: pos.isMeasured ? scale * pos.m : null,
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

      final pos = source.asPosition;
      var x = pos.x;
      var y = pos.y;

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
