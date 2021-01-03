// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../../model/common.dart';

import 'resource.dart';

/// A base interface representing a provider for some data source like API.
abstract class Provider<M extends ProviderMeta, C extends Resource> {
  /// Overview metadata for this provider.
  ///
  /// Normally a provider implementation retrieves metadata once on a session
  /// and caches data on an in-memory cache, but design choices are open.
  Future<M> meta();

  /// Returns a collection resource by [id] for a subset of a data source.
  Future<C> collection(String id);
}
