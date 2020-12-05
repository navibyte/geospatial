// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import '../../model/geo/common.dart';

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

/// A base interface representing a resource for a subset of some data source.
///
/// Normally a resource has nested or sub resources accessible via sub types.
abstract class Resource {}

/// A base interface for a paged response of a item set with a link to next one.
abstract class Paged<I> {
  /// The [current] response containing some items.
  I get current;

  /// True if there exists [next] set of items on a resource.
  bool get hasNext;

  /// Fetches [next] set of items from a resource.
  ///
  /// Please note that calling this many times initiates fetches to the same
  /// next set of items compared to [current] set. So normally call this once.
  ///
  /// Throws StateError if a next item set isn't available ([hasNext] == false).
  Future<Paged<I>> next();

  // todo : hasPrev, prev
}
