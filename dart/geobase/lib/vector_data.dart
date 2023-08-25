// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars

/// Data structures for positions, geometries, features and feature collections.
///
/// Key features:
/// * positions and position arrays based on coordinate arrays
/// * simple geometries (point, line string, polygon, multi point, multi line string, multi polygon, geometry collection)
/// * features (with id, properties and geometry) and feature collections
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/vector_data.dart`
library vector_data;

export 'src/vector_data/array/coordinates.dart';
export 'src/vector_data/array/coordinates_extensions.dart';
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
