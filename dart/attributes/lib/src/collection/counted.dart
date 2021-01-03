// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An interface for a collection with countable items.
abstract class Counted {
  const Counted();

  /// Returns the number of direct childs on the collection.
  ///
  /// If not applicable or not known then 0 should be returned.
  int get length;
}
