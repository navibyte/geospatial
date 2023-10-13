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
