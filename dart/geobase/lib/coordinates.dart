// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Position, bounding box and positions series (with coordinate arrays).
///
/// Contains also geographic (longitude-latitude) and projected positions and
/// bounding boxes, scalable coordinates, and projection abstraction classes.
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/coordinates.dart`
library coordinates;

export 'src/common/codes/axis_order.dart';
export 'src/common/codes/cardinal_precision.dart';
export 'src/common/codes/coords.dart';
export 'src/common/codes/dimensionality.dart';
export 'src/common/codes/dms_type.dart';
export 'src/common/codes/geo_representation.dart';
export 'src/common/constants/epsilon.dart';
export 'src/coordinates/base/aligned.dart';
export 'src/coordinates/base/bounded.dart';
export 'src/coordinates/base/box.dart';
export 'src/coordinates/base/position.dart';
export 'src/coordinates/base/position_extensions.dart';
export 'src/coordinates/base/position_scheme.dart';
export 'src/coordinates/base/position_series.dart';
export 'src/coordinates/base/positionable.dart';
export 'src/coordinates/base/value_positionable.dart';
export 'src/coordinates/geographic/geobox.dart';
export 'src/coordinates/geographic/geographic.dart';
export 'src/coordinates/geographic/geographic_bearing.dart';
export 'src/coordinates/projected/projbox.dart';
export 'src/coordinates/projected/projected.dart';
export 'src/coordinates/projection/projection.dart';
export 'src/coordinates/projection/projection_adapter.dart';
export 'src/coordinates/scalable/scalable.dart';
export 'src/coordinates/scalable/scalable2i.dart';
