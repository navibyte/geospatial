// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/constants/epsilon.dart';
import '/src/vector_data/model/bounded/bounded.dart';

import 'tolerance.dart';

/// True if [b1] and [b2] contain exactly same coordinate values
/// (or both are empty) in the same order and with the same coordinate type.
///
/// The [test] function should test only coordinate data.
///
/// This static method helps implementing [Bounded.equalsCoords] in subtypes.
@internal
bool testEqualsCoords<T extends Bounded>(
  Bounded b1,
  Bounded b2,
  bool Function(T, T) test,
) {
  // require both bounded objects are of same type
  if (b1 is! T || b2 is! T) return false;

  // check if refering to the same instance
  if (identical(b1, b2)) return true;

  // test bounding boxes if both bounded objects have it
  final bb1 = b1.bounds;
  final bb2 = b2.bounds;
  if (bb1 != null && bb2 != null && bb1 != bb2) {
    // both bounded objects has bounding boxes and boxes do not equal
    return false;
  }

  // use given test function to test actual geometries / coordinates
  return test.call(b1, b2);
}

/// True if [b1] equals with [b2] by testing 2D coordinates
/// of all geometries (that must be in same order in both objects) contained
/// directly or by child objects.
///
/// This static method helps implementing [Bounded.equals2D] in subtypes.
@internal
bool testEquals2D<T extends Bounded>(
  Bounded b1,
  Bounded b2,
  bool Function(T, T) test, {
  double toleranceHoriz = defaultEpsilon,
}) {
  assertTolerance(toleranceHoriz);

  // require both bounded objects are of same type, and not empty
  if (b1 is! T || b2 is! T) return false;
  if (b1.isEmptyByGeometry || b2.isEmptyByGeometry) return false;

  // check if refering to the same instance
  if (identical(b1, b2)) return true;

  // test bounding boxes if both bounded objects have it
  final bb1 = b1.bounds;
  final bb2 = b2.bounds;
  if (bb1 != null &&
      bb2 != null &&
      !bb1.equals2D(
        bb2,
        toleranceHoriz: toleranceHoriz,
      )) {
    // both bounded objects has bounding boxes and boxes do not equal in 2D
    return false;
  }

  // use given test function to test actual geometries / coordinates
  return test.call(b1, b2);
}

/// True if [b1] equals with [b2] by testing 3D coordinates
/// of all geometries (that must be in same order in both objects) contained
/// directly or by child objects.
///
/// This static method helps implementing [Bounded.equals3D] in subtypes.
@internal
bool testEquals3D<T extends Bounded>(
  Bounded b1,
  Bounded b2,
  bool Function(T, T) test, {
  double toleranceHoriz = defaultEpsilon,
  double toleranceVert = defaultEpsilon,
}) {
  assertTolerance(toleranceHoriz);
  assertTolerance(toleranceVert);

  // require both bounded objects are of same type, 3D coords, and not empty
  if (b1 is! T || b2 is! T) return false;
  if (b1.isEmptyByGeometry || b2.isEmptyByGeometry) return false;
  if (!b1.coordType.is3D || !b2.coordType.is3D) return false;

  // check if refering to the same instance
  // NOTE: commented out, does not work as expected, need to refine coord types
  // if (identical(b1, b2)) return true;

  // test bounding boxes if both bounded objects have it
  final bb1 = b1.bounds;
  final bb2 = b2.bounds;
  if (bb1 != null &&
      bb2 != null &&
      !bb1.equals3D(
        bb2,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      )) {
    // both bounded objects has bounding boxes and boxes do not equal in 3D
    return false;
  }

  // use given test function to test actual geometries / coordinates
  return test.call(b1, b2);
}
