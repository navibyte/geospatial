// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:http/http.dart' as http;

import 'http_content.dart';
import 'http_exception.dart';

/// A function to validate a HTTP response, and return [HttpContent] if success.
///
/// Should throw a [HttpException] if a response is not successul (ie. other
/// than HTTP 200 OK - or other validation rules depending on the use case).
typedef HttpValidator = HttpContent Function(
    Uri reference, http.BaseResponse response);
