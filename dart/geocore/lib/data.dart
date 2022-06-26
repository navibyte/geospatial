// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Geospatial features and geometries (linestring, polygon, multi geometries).
///
/// This library exports also all classes of `package:geocore/base.dart` and
/// `package:geocore/coordinates.dart`.
///
/// Exports also `Coords`, `Position`, `TransformPosition`, `CreatePosition`,
/// `Box` and `Projection` from `package:geobase/coordinates.dart`.
///
/// Exports also `Geom`, `CoordinateContent`, `SimpleGeometryContent`, 
/// `GeometryContent`, `GeometryFormat`, `FeatureContent`, `FeatureFormat`, 
/// `PropertyContent`, `ContentWriter`, `defaultFormat`, `wktLikeFormat`, 
/// `GeoJSON` and `WKT` from `package:geobase/vector.dart`.
///
/// Usage: import `package:geocore/data.dart`
library data;

export 'package:geobase/vector.dart'
    show
        Geom,
        CoordinateContent,
        SimpleGeometryContent,
        GeometryContent,
        GeometryFormat,
        FeatureContent,
        FeatureFormat,
        PropertyContent,
        ContentWriter,
        defaultFormat,
        wktLikeFormat,
        GeoJSON,
        WKT;

export 'base.dart';
export 'coordinates.dart';

export 'src/data/feature.dart';
export 'src/data/simple_geometry.dart';
