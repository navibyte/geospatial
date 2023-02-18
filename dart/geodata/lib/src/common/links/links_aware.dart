// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'links.dart';

/// A mixin aware of links.
mixin LinksAware {
  /// Links related to this object.
  Links get links => const Links.empty();
}
