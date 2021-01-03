// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:async';

import 'query.dart';
import 'content.dart';

/// An API client abstraction.
// ignore: one_member_abstracts
abstract class ApiClient {
  /// Reads content from an API according to the [query].
  ///
  /// Failures on forming a request, calling an API, fetching data or handling
  /// a response are thrown as exceptions by a client implementation.
  Future<Content> read(Query query);
}
