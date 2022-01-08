// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A mixin to handle sets of some items as paged responses.
mixin Paged<T> {
  /// The current set of items.
  T get current;

  /// True if there exists a [next] set of items on a resource.
  bool get hasNext;

  /// Get a next set of items from a resource asynchronously.
  ///
  /// Returns null if a next set of items isn't available.
  Future<Paged<T>?> next();

  /// True if there exists a [previous] set of items on a resource.
  bool get hasPrevious => false;

  /// Get a previous set of items from a resource asynchronously.
  ///
  /// Returns null if a previous set of items isn't available.
  Future<Paged<T>?> previous() => Future.value(null);
}
