// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars

/// Geospatial data structures, projections, tiling schemes and vector data.
///
/// Key features:
/// * geographic (longitude-latitude) and projected positions and bounding boxes
/// * simple geometries (point, line string, polygon, multi point, multi line string, multi polygon, geometry collection)
/// * features (with id, properties and geometry) and feature collections
/// * temporal data structures (instant, interval) and spatial extents
/// * vector data formats supported ([GeoJSON](https://geojson.org/), [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry), [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary))
/// * coordinate projections (web mercator + based on the external [proj4dart](https://pub.dev/packages/proj4dart) library)
/// * tiling schemes and tile matrix sets (web mercator, global geodetic)///
///
/// Usage: import `package:geobase/geobase.dart`
library geobase;

export 'src/codes/canvas_origin.dart';
export 'src/codes/coords.dart';
export 'src/codes/geom.dart';
export 'src/constants/geodetic.dart';
export 'src/constants/screen_ppi.dart';
export 'src/coordinates/base.dart';
export 'src/coordinates/data.dart';
export 'src/coordinates/geographic.dart';
export 'src/coordinates/projected.dart';
export 'src/coordinates/projection.dart';
export 'src/coordinates/scalable.dart';
export 'src/geodesy/spherical.dart';
export 'src/meta/extent.dart';
export 'src/meta/time.dart';
export 'src/projections/wgs84.dart';
export 'src/tiling/convert.dart';
export 'src/tiling/tilematrix.dart';
export 'src/vector/content.dart';
export 'src/vector/encoding.dart';
export 'src/vector/formats.dart';
export 'src/vector_data/array.dart';
export 'src/vector_data/coords.dart';
export 'src/vector_data/model.dart';
