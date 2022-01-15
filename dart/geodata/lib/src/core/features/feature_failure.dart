// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A failure type for failures that could occur when accessing features.
enum FeatureFailure {
  /// An error occurred on the client side.
  clientError,

  /// A service returned `Bad request` (ie. HTTP 400) for a query.
  badRequest,

  /// A service returned `Not found` (ie. HTTP 404) for a query.
  notFound,

  /// A query failed for undefined reasons.
  queryFailed,
}
