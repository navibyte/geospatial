// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A geospatial client to read GeoJSON and other geospatial data sources.
///
/// Usage: import `package:geodata/geodata.dart`
library geodata;

// todo: new mini libraries
// export 'base.dart';
// export 'common.dart'; 
// export 'geojson_features.dart';
// export 'ogcapi_features.dart';

// Export mini-libraries forming the whole "geodata" library.
export 'api_common.dart';
export 'api_features.dart';
export 'geojson_features.dart';
export 'oapi_common.dart';
export 'oapi_features.dart';
