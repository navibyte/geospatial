// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars

/// Data structures for geometries, geometry collections, features and feature
/// collections.
///
/// Key features:
/// * simple geometries (point, line string, polygon, multi point, multi line
///   string, multi polygon) and geometry collections
/// * features (with id, properties and geometry) and feature collections
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/vector_data.dart`
library vector_data;

export 'src/common/codes/coords.dart';
export 'src/common/codes/dimensionality.dart';
export 'src/common/codes/geom.dart';
export 'src/common/reference/coord_ref_sys.dart';
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
