// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A geospatial client reading OGC API and other geospatial data sources.
///
/// Usage: import `package:geodata/geodata.dart`
library geodata;

// Export mini-libraries forming the whole "geodata" library.

// models
export 'model_base.dart';
export 'model_common.dart';
export 'model_features.dart';

// providers
export 'provider_common.dart';
export 'provider_features.dart';

// (data) sources
export 'source_oapi_common.dart';
export 'source_oapi_features.dart';
