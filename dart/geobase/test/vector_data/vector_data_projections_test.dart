// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:geobase/geobase.dart';
import 'package:test/test.dart';

import '../projections/projection_sample.dart';

void main() {
  group('Test vector data structures and coordinate projections', () {
    const adapter = WGS84.webMercator;
    final forward = adapter.forward;
    final inverse = adapter.inverse;

    test('PositionCoords and Point', () {
      for (var dim = 2; dim <= 4; dim++) {
        final type = Coords.fromDimension(dim);
        for (final coords in wgs84ToWebMercatorData) {
          final geo = PositionCoords.create(
            x: coords[0],
            y: coords[1],
            z: type.is3D ? 12.3 : null,
            m: type.isMeasured ? 3.9 : null,
          );
          final proj = PositionCoords.create(
            x: coords[2],
            y: coords[3],
            z: type.is3D ? 12.3 : null,
            m: type.isMeasured ? 3.9 : null,
          );
          expectPosition(
            forward.project(geo, to: PositionCoords.create),
            proj,
            0.01,
          );
          expectPosition(
            inverse.project(proj, to: PositionCoords.create),
            geo,
            0.01,
          );
          final geoPoint = Point(geo);
          final projPoint = Point(proj);
          expectPosition(
            geoPoint.project(forward).position,
            proj,
            0.01,
          );
          expectPosition(
            projPoint.project(inverse).position,
            geo,
            0.01,
          );
        }
      }
    });

    test('PositionArray and LineString', () {
      for (var dim = 2; dim <= 4; dim++) {
        final type = Coords.fromDimension(dim);
        final pointCount = wgs84ToWebMercatorData.length;
        final source = List.filled(dim * pointCount, 10.0);
        final target = List.filled(dim * pointCount, 10.0);
        for (var i = 0; i < pointCount; i++) {
          final sample = wgs84ToWebMercatorData[i];
          source[i * dim] = sample[0];
          source[i * dim + 1] = sample[1];
          target[i * dim] = sample[2];
          target[i * dim + 1] = sample[3];
        }
        final sourceArray = PositionArray.view(source, type: type);
        final targetArray = PositionArray.view(target, type: type);
        expectCoords(
          sourceArray.project(forward).toList(),
          target,
          0.01,
        );
        expectCoords(
          targetArray.project(inverse).toList(),
          source,
          0.01,
        );
        final sourceLineString = LineString(sourceArray);
        final targetLineString = LineString(targetArray);
        expectCoords(
          sourceLineString.project(forward).chain.toList(),
          target,
          0.01,
        );
        expectCoords(
          targetLineString.project(inverse).chain.toList(),
          source,
          0.01,
        );
      }
    });
  });
}
