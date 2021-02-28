// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An exception occurred when accessing an API.
///
/// There are two direct sub classes defined on this package:
/// * [ClientException] - accessing an API and caused by client-side code
/// * [OriginException] - caused by validation of a response from an API origin
class ApiException implements Exception {
  const ApiException(this.message, {this.reference});

  /// The descriptive [message].
  final String message;

  /// An optional URI [reference] for an API resoure.
  final Uri? reference;

  @override
  String toString() => message;
}
