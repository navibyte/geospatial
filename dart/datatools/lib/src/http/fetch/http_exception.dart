// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:http/http.dart' as http;

import '../../api/exceptions.dart';

/// An exception originating from a HTTP response with non-success status code.
class HttpException extends OriginException {
  HttpException(Uri reference, this.response, {String? message})
      : super(message ?? _message(reference, response), uri: reference);

  /// The HTTP [response] that caused this exception.
  final http.BaseResponse response;

  @override
  OriginFailure get failure => _failure(response.statusCode);

  @override
  int get statusCode => response.statusCode;

  @override
  String? get reasonPhrase => response.reasonPhrase;

  static OriginFailure _failure(int status) {
    switch (status) {
      case 304:
        return OriginFailure.notModified;
      case 400:
        return OriginFailure.badRequest;
      case 401:
        return OriginFailure.unauthorized;
      case 403:
        return OriginFailure.forbidden;
      case 404:
        return OriginFailure.notFound;
      case 406:
        return OriginFailure.notAcceptable;
    }
    return OriginFailure.undefined;
  }

  static String _message(
    Uri reference,
    http.BaseResponse response,
  ) {
    var msg = 'Request to $reference failed with status ${response.statusCode}';
    if (response.reasonPhrase != null) {
      msg = '$msg: ${response.reasonPhrase}';
    }
    return msg;
  }
}
