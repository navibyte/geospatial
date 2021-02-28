// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'api_exception.dart';

/// Common failure types related to [OriginException].
///
/// Note: this is not protocol specific failure type, so this enumeration does
/// not list all those familiar status codes of HTTP protocol.
enum OriginFailure {
  undefined,
  notModified,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  notAcceptable,
}

/// An exception containing a failure message as a response from an API origin.
abstract class OriginException extends ApiException {
  const OriginException(String message, {Uri? uri})
      : super(message, reference: uri);

  factory OriginException.of(String message,
      {Uri? uri,
      OriginFailure failure,
      int statusCode,
      String? reasonPhrase}) = _OriginExceptionBase;

  /// Common failure type. By default `undefined` if not set.
  OriginFailure get failure => OriginFailure.undefined;

  /// Protocol (like HTTP) specific status code. By default 0 if not set.
  int get statusCode => 0;

  /// Protocol (like HTTP) specific reason phrase. By default nul if not set.
  String? get reasonPhrase => null;

  bool get isNotModified => failure == OriginFailure.notModified;

  bool get isBadRequest => failure == OriginFailure.badRequest;

  bool get isUnauthorized => failure == OriginFailure.unauthorized;

  bool get isForbidden => failure == OriginFailure.forbidden;

  bool get isNotFound => failure == OriginFailure.notFound;

  bool get isNotAcceptable => failure == OriginFailure.notAcceptable;
}

class _OriginExceptionBase extends OriginException {
  const _OriginExceptionBase(String message,
      {Uri? uri,
      this.failure = OriginFailure.undefined,
      this.statusCode = 0,
      this.reasonPhrase})
      : super(message, uri: uri);

  @override
  final OriginFailure failure;

  @override
  final int statusCode;

  @override
  final String? reasonPhrase;
}
