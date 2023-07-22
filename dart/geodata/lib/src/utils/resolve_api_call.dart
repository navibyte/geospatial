// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

/// Creates an API call path that has [subResource] as a sub path for [endpoint]
/// regardless wether [endpoint] has a postfix `/` character.
///
/// The [subResource] should not start with `/', or such a resource shall be
/// resolved directly under the host of [endpoint].
@internal
Uri resolveAPICall(Uri endpoint, String subResource) {
  final basePath = endpoint.path;
  if (basePath.endsWith('/')) {
    return endpoint.resolve(subResource);
  } else {
    return endpoint.replace(path: '$basePath/').resolve(subResource);
  }
}

/// Creates an API call path that has [subResource] as a sub path for [endpoint]
/// regardless wether [endpoint] has a postfix `/` character.
///
/// The [subResource] should not start with `/', or such a resource shall be
/// resolved directly under the host of [endpoint].
@internal
Uri resolveAPICallUri(Uri endpoint, Uri subResource) {
  final basePath = endpoint.path;
  if (basePath.endsWith('/')) {
    return endpoint.resolveUri(subResource);
  } else {
    return endpoint.replace(path: '$basePath/').resolveUri(subResource);
  }
}
