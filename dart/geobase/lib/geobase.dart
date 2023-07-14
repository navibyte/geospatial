// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
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
/// * tiling schemes and tile matrix sets (web mercator, global geodetic)
/// * spherical geodesy tools
///
/// Usage: import `package:geobase/geobase.dart`
library geobase;

// codes
export 'src/codes/canvas_origin.dart';
export 'src/codes/coords.dart';
export 'src/codes/geom.dart';

// constants
export 'src/constants/geodetic.dart';
export 'src/constants/screen_ppi.dart';

// coordinates
export 'src/coordinates/base/aligned.dart';
export 'src/coordinates/base/box.dart';
export 'src/coordinates/base/measurable.dart';
export 'src/coordinates/base/position.dart';
export 'src/coordinates/base/positionable.dart';
export 'src/coordinates/data/position_data.dart';
export 'src/coordinates/geographic/dms.dart';
export 'src/coordinates/geographic/geobox.dart';
export 'src/coordinates/geographic/geographic.dart';
export 'src/coordinates/geographic/geographic_functions.dart';
export 'src/coordinates/projected/projbox.dart';
export 'src/coordinates/projected/projected.dart';
export 'src/coordinates/projection/projection.dart';
export 'src/coordinates/projection/projection_adapter.dart';
export 'src/coordinates/scalable/scalable.dart';
export 'src/coordinates/scalable/scalable2i.dart';

// geodesy
export 'src/geodesy/spherical/distance_haversine.dart';
export 'src/geodesy/spherical/spherical_great_circle.dart';
export 'src/geodesy/spherical/spherical_rhumb_line.dart';

// meta
export 'src/meta/extent/geo_extent.dart';
export 'src/meta/extent/spatial_extent.dart';
export 'src/meta/extent/temporal_extent.dart';
export 'src/meta/time/instant.dart';
export 'src/meta/time/interval.dart';
export 'src/meta/time/temporal.dart';

// projections
export 'src/projections/wgs84/wgs84.dart';

// tiling
export 'src/tiling/convert/scaled_converter.dart';
export 'src/tiling/tilematrix/base/geo_tile_matrix_set.dart';
export 'src/tiling/tilematrix/base/tile_matrix_set.dart';
export 'src/tiling/tilematrix/mercator/web_mercator_quad.dart';
export 'src/tiling/tilematrix/plate_carree/global_geodetic_quad.dart';

// vector
export 'src/vector/content/coordinates_content.dart';
export 'src/vector/content/feature_content.dart';
export 'src/vector/content/geometry_content.dart';
export 'src/vector/content/property_content.dart';
export 'src/vector/content/simple_geometry_content.dart';
export 'src/vector/encoding/binary_format.dart';
export 'src/vector/encoding/content_decoder.dart';
export 'src/vector/encoding/content_encoder.dart';
export 'src/vector/encoding/text_format.dart';
export 'src/vector/formats/geojson/default_format.dart';
export 'src/vector/formats/geojson/geojson_format.dart';
export 'src/vector/formats/wkb/wkb_conf.dart';
export 'src/vector/formats/wkb/wkb_format.dart';
export 'src/vector/formats/wkt/wkt_format.dart';
export 'src/vector/formats/wkt/wkt_like_format.dart';

// vector_data
export 'src/vector_data/array/coordinates.dart';
export 'src/vector_data/array/list_coordinate_extension.dart';
export 'src/vector_data/coords/lonlat.dart';
export 'src/vector_data/coords/xy.dart';
export 'src/vector_data/model/bounded/bounded.dart';
export 'src/vector_data/model/feature/feature.dart';
export 'src/vector_data/model/feature/feature_builder.dart';
export 'src/vector_data/model/feature/feature_collection.dart';
export 'src/vector_data/model/feature/feature_object.dart';
export 'src/vector_data/model/geometry/geometry.dart';
export 'src/vector_data/model/geometry/geometry_builder.dart';
export 'src/vector_data/model/geometry/geometry_collection.dart';
export 'src/vector_data/model/geometry/linestring.dart';
export 'src/vector_data/model/geometry/multi_linestring.dart';
export 'src/vector_data/model/geometry/multi_point.dart';
export 'src/vector_data/model/geometry/multi_polygon.dart';
export 'src/vector_data/model/geometry/point.dart';
export 'src/vector_data/model/geometry/polygon.dart';
