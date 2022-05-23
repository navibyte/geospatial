// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Base classes for geospatial geometries objects.
///
/// *Spatial* classes include coordinates, points, bounds, point series, and
/// transform and projection abstractions.
/// 
/// Exports also Coords, Position, TransformPosition, CreatePosition, Box and
/// Projection from 'package:geobase/coordinates.dart'.
///
/// Usage: import `package:geocore/base.dart`
library base;

export 'package:geobase/coordinates.dart'
    show Coords, Position, TransformPosition, CreatePosition, Box, Projection;

export 'src/base/spatial.dart';
