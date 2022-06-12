// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Geospatial data (geometry, features, meta) and parsers (WKT, GeoJSON).
///
/// Exports `Coords`, `Position`, `TransformPosition`, `CreatePosition`, `Box`
/// and `Projection` from `package:geobase/coordinates.dart`.
///
/// Exports also `Geom`, `GeometryWriter`, `GeometryFormat`, `FeatureWriter`,
/// `FeatureFormat`, `defaultFormat`, `wktLikeFormat`, `geoJsonFormat` and
/// `wktFormat` from `package:geobase/vector.dart`.
///
/// Usage: import `package:geocore/geocore.dart`
library geocore;

// Export mini-libraries forming the whole "geocore" library.
export 'base.dart';
export 'coordinates.dart';
export 'data.dart';

export 'src/parse/factory.dart';
export 'src/parse/geojson.dart';
export 'src/parse/wkt.dart';
