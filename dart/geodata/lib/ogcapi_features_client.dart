// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A client-side data source to read features from OGC API Features services.
///
/// This library exports also all classes of `package:geodata/common.dart` and
/// `package:geodata/core.dart`.
///
/// Usage: import `package:geodata/ogcapi_features_client.dart`
library ogcapi_features_client;

export 'common.dart';
export 'core.dart';

export 'src/ogcapi_common/model/ogc_collection_meta.dart';
export 'src/ogcapi_common/model/ogc_conformance.dart';
export 'src/ogcapi_common/model/ogc_service.dart';
export 'src/ogcapi_common/model/ogc_service_meta.dart';
export 'src/ogcapi_features/model/ogc_feature_conformance.dart';
export 'src/ogcapi_features/model/ogc_feature_item.dart';
export 'src/ogcapi_features/model/ogc_feature_items.dart';
export 'src/ogcapi_features/model/ogc_feature_service.dart';
export 'src/ogcapi_features/model/ogc_feature_source.dart';
export 'src/ogcapi_features/service/client/ogc_feature_client.dart';
