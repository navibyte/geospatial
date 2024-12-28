// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

/// An exception that may occur when accessing app business logic or a service.
///
/// The required [failure] property provides an app specific failure of the type
/// [T].
///
/// An optional source for the exception is provided by [cause] and [trace].
@immutable
class ServiceException<T extends Object> implements Exception {
  /// Create an exception with [failure], and optional [cause] and [trace].
  const ServiceException(this.failure, {this.cause, this.trace});

  /// The app specific failure as an object of [T].
  final T failure;

  /// An optional source that caused the exception.
  ///
  /// This could be for example another exception, an error instance or a String
  /// object.
  final Object? cause;

  /// An optional stack trace that is accociated with an optional [cause].
  final StackTrace? trace;

  @override
  String toString() => '$failure${cause != null ? " ($cause)" : ""}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceException<T> &&
          failure == other.failure &&
          cause == other.cause &&
          trace == other.trace);

  @override
  int get hashCode => Object.hash(failure, cause, trace);
}
