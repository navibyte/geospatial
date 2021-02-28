// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../exceptions.dart';

/// A function to resolve an absolute URI from an URI [reference].
///
/// Throws [ClientException] if the given [reference] is not allowed
/// according to security policies of a resolver, or if it's not resolvable.
typedef UriResolver = Uri Function(Uri reference);
