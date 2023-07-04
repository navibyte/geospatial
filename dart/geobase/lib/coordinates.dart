// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Geographic (longitude-latitude) and projected positions and bounding boxes.
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/coordinates.dart`
library coordinates;

export 'src/codes/coords.dart';
export 'src/coordinates/base/aligned.dart';
export 'src/coordinates/base/box.dart';
export 'src/coordinates/base/measurable.dart';
export 'src/coordinates/base/position.dart';
export 'src/coordinates/base/positionable.dart';
export 'src/coordinates/data/position_data.dart';
export 'src/coordinates/geographic/geobox.dart';
export 'src/coordinates/geographic/geographic.dart';
export 'src/coordinates/geographic/geographic_functions.dart';
export 'src/coordinates/projected/projbox.dart';
export 'src/coordinates/projected/projected.dart';
export 'src/coordinates/projection/projection.dart';
export 'src/coordinates/projection/projection_adapter.dart';
export 'src/coordinates/scalable/scalable.dart';
export 'src/coordinates/scalable/scalable2i.dart';
