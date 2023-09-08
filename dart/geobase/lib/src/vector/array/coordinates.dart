// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/constants/epsilon.dart';
import '/src/coordinates/base/aligned.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/positionable.dart';
import '/src/coordinates/data/position_data.dart';
import '/src/coordinates/geographic/geographic.dart';
import '/src/coordinates/projected/projected.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/utils/coord_utils.dart';
import '/src/utils/format_validation.dart';
import '/src/utils/num.dart';

part 'box_coords.dart';
part 'coordinates_mixin.dart';
part 'position_array.dart';
part 'position_coords.dart';

/// Geospatial coordinate values as an iterable collection of double values.
///
/// See also sub classes:
/// * [PositionArray]: coordinate values of 0 to N positions in a flat structure
/// * [PositionCoords]: coordinate values of a single position
/// * [BoxCoords]: coordinate values of a single bounding box
@Deprecated('Use Position, PositionSeries or Box instead')
abstract class Coordinates extends Iterable<double> implements Positionable {}
