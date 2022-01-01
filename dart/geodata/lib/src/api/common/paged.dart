// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

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
