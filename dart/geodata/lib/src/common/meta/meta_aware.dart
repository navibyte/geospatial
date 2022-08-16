// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A mixin aware of metadata for something.
mixin MetaAware {
  /// Metadata as a data object (ie. data from a JSON Object).
  Map<String, dynamic> get meta => const {};
}
