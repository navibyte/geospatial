// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A geospatial client to read GeoJSON and OGC API Features data sources.
///
/// Usage: import `package:geodata/geodata.dart`
library geodata;

// Export mini-libraries forming the whole "geodata" library.
export 'common.dart';
export 'core.dart';
export 'formats.dart';
export 'geojson_client.dart';
export 'ogcapi_features_client.dart';
