// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An exception that could occur when accessing some service.
class ServiceException<T> implements Exception {
  /// Create an exception.
  const ServiceException(this.failure, {this.cause, this.trace});

  /// The failure as an object of [T].
  final T failure;

  /// An optional source that caused the exception.
  ///
  /// Could be another exception or error instance, or a String object.
  final Object? cause;

  /// An optional stack trace that is accociated to an optional [cause].
  final StackTrace? trace;

  @override
  String toString() => failure.toString();
}
