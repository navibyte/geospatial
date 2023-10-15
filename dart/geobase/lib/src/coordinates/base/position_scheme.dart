// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'box.dart';
import 'position.dart';

/// A position scheme encapsulates position and bounding box factories for
/// certain type of position data.
///
/// There are following known static constant instances available:
/// * `Position.scheme` to create positions and boxes for any position data
///   (geographic, projected or any other)
/// * `Projected.scheme` to create projected positions and boxes
/// * `Geographic.scheme` to create geographic positions and boxes
///
/// Examples (represented as test cases):
///
/// ```dart
/// // a multi line string with two lines (when interpreted as geographic
/// // coordinates another west from and another east from the antimeridian)
/// final lines = [
///   [177.0, -20.0, 178.0, -19.0, 179.0, -18.0].positions(Coords.xy),
///   [-179.0, -17.0, -178.0, -16.0].positions(Coords.xy)
/// ];
/// final mls = MultiLineString(lines);
///
/// // a minimum bounding box calculated from this geometry varies by scheme
///
/// // `Position.scheme`: a minimum bounding box is calculated mathematically
/// final b = Box.create(minX: -179.0, minY: -20.0, maxX: 179.0, maxY: -16.0);
/// expect(mls.calculateBounds(scheme: Position.scheme), b);
/// expect(mls.populated(scheme: Position.scheme).bounds, b);
///
/// // `Projected.scheme`: a minimum bounding box is calculated mathematically
/// const proj = ProjBox(minX: -179.0, minY: -20.0, maxX: 179.0, maxY: -16.0);
/// expect(mls.calculateBounds(scheme: Projected.scheme), proj);
/// expect(mls.populated(scheme: Projected.scheme).bounds, proj);
///
/// // `Geographic.scheme`: a minimum bounding box is calculated
/// // geographically and in this case it spans the antimeridian (that is
/// // `west > east` even if normally `west <= east` when not spanning)
/// const geo = GeoBox(west: 177.0, south: -20.0, east: -178.0, north: -16.0);
/// expect(mls.calculateBounds(scheme: Geographic.scheme), geo);
/// expect(mls.populated(scheme: Geographic.scheme).bounds, geo);
/// ```
@immutable
class PositionScheme {
  final CreatePosition _position;
  final CreateBox _box;

  /// A position scheme with [position] and bounding [box] factories.
  ///
  /// Normally you should not need to create an instance of [PositionScheme] but
  /// rather use one of static constant instances available:
  /// * `Position.scheme` to create positions and boxes for any position data
  ///   (geographic, projected or any other)
  /// * `Projected.scheme` to create projected positions and boxes
  /// * `Geographic.scheme` to create geographic positions and boxes
  const PositionScheme({
    required CreatePosition position,
    required CreateBox box,
  })  : _position = position,
        _box = box;

  /// The factory to create positions.
  CreatePosition get position => _position;

  /// The factory to create bounding boxes.
  CreateBox get box => _box;
}
