// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Text and binary formats for vector data (features, geometries, coordinates).
///
/// Key features:
/// * text format writers and parsers for features, geometries, coordinates,
///   properties:
///   * supported formats: [GeoJSON](https://geojson.org/)
/// * text format writers and parsers for geometries and coordinates:
///   * supported formats: [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
/// * binary format encoders and decoders for geometries:
///   * supported formats: [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary)
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/vector.dart`
library vector;

export 'src/codes/geom.dart';
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
export 'src/vector/formats/wkb/wkb_format.dart';
export 'src/vector/formats/wkt/wkt_format.dart';
export 'src/vector/formats/wkt/wkt_like_format.dart';
