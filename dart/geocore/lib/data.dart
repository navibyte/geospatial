// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
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
/// `GeometryContent`, `GeometryBinaryFormat`, `FeatureContent`,
/// `PropertyContent`, `ContentDecoder`, `ContentEncoder`, `BinaryFormat`,
/// `TextWriterFormat`, `DefaultFormat`, `WktLikeFormat`, `GeoJSON`, `WKT` and
/// `WKB` from `package:geobase/vector.dart`.
///
/// Usage: import `package:geocore/data.dart`
library data;

export 'package:geobase/vector.dart'
    show
        BinaryFormat,
        ContentDecoder,
        ContentEncoder,
        CoordinateContent,
        DefaultFormat,
        FeatureContent,
        GeoJSON,
        Geom,
        GeometryContent,
        PropertyContent,
        SimpleGeometryContent,
        TextWriterFormat,
        WKB,
        WKT,
        WktLikeFormat;

export 'base.dart';
export 'coordinates.dart';

export 'src/data/feature.dart';
export 'src/data/simple_geometry.dart';
