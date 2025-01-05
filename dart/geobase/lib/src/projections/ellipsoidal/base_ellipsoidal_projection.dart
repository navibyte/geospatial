// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import 'package:meta/meta.dart';

import '/src/common/codes/coords.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/geodesy/ellipsoidal/datum.dart';
import '/src/utils/format_validation.dart';

@internal
abstract class BaseEllipsoidalProjection<SourceType extends Position,
    TargetType extends Position> with Projection {
  @protected
  final Datum sourceDatum;

  @protected
  final Datum targetDatum;

  const BaseEllipsoidalProjection({
    required this.sourceDatum,
    required this.targetDatum,
  });

  @protected
  TargetType projectPosition(SourceType source);

  @protected
  TargetType projectXYZM(double x, double y, double? z, double? m);

  @override
  List<double> projectCoords(
    Iterable<double> source, {
    List<double>? target,
    required Coords type,
  }) {
    /// This is a default implementation that uses the [projectXYZM] method to
    /// project each position in the [source] array. Subclasses may override
    /// this method to provide more efficient implementations.

    final dim = type.coordinateDimension;
    final hasZ = type.is3D;
    final hasM = type.isMeasured;
    final result = target ?? Float64List(source.length);

    var offset = 0;
    final iter = source.iterator;
    while (iter.moveNext()) {
      // get source coordinates from the coordinate value iterator
      final coord0 = iter.current;
      final coord1 = iter.moveNext() ? iter.current : throw invalidCoordinates;
      final coord2 = dim >= 3
          ? (iter.moveNext() ? iter.current : throw invalidCoordinates)
          : null;
      final coord3 = dim >= 4
          ? (iter.moveNext() ? iter.current : throw invalidCoordinates)
          : null;

      // convert source to target position coordinates
      final targetPosition = projectXYZM(
        coord0, // x
        coord1, // y
        hasZ ? coord2 : null, // z
        hasZ ? coord3 : coord2, // m
      );

      // set target coordinates to the result array
      result[offset] = targetPosition.x;
      result[offset + 1] = targetPosition.y;
      if (hasZ) {
        result[offset + 2] = targetPosition.z;
        if (hasM) {
          result[offset + 3] = targetPosition.m;
        }
      } else {
        if (hasM) {
          result[offset + 2] = targetPosition.m;
        }
      }

      offset += dim;
    }

    return result;
  }
}
