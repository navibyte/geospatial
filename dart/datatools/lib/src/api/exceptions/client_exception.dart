// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'api_exception.dart';

/// An exception occurred when accessing an API and caused by client-side code.
class ClientException extends ApiException {
  const ClientException(String message, {Uri? uri, this.cause})
      : super(message, reference: uri);

  /// An optional wrapped [cause] exception.
  final dynamic cause;

  static ClientException notRelative(Uri uri) =>
      ClientException('$uri is not relative reference', uri: uri);

  static ClientException uriNotAllowed(Uri uri) =>
      ClientException('$uri is not allowed', uri: uri);

  static ClientException failed(Uri uri, dynamic cause) =>
      ClientException('Calling $uri failed: $cause', cause: cause, uri: uri);

  static ClientException openingStreamFailed(dynamic cause) =>
      ClientException('Opening stream failed: $cause', cause: cause);

  static ClientException readingTextFailed(dynamic cause) =>
      ClientException('Reading text failed: $cause', cause: cause);

  static ClientException readingBytesFailed(dynamic cause) =>
      ClientException('Reading bytes failed: $cause', cause: cause);

  static ClientException decodingJsonFailed(dynamic cause) =>
      ClientException('Decoding json failed: $cause', cause: cause);
}
