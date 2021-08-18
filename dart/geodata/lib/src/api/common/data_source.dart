// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'data_source_meta.dart';

/// A data source (like an API service or other resource).
abstract class DataSource<M extends DataSourceMeta> {
  /// Default `const` constructor to allow extending this abstract class.
  const DataSource();

  /// Overview metadata for this data source.
  ///
  /// Normally a data source implementation retrieves metadata once on a session
  /// and caches data on an in-memory cache, but design choices are open.
  Future<M> meta();
}
