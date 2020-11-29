// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

/// An endpoint defining at least a [baseUrl] for some API service.
@immutable
class Endpoint with EquatableMixin {
  const Endpoint.url(this.baseUrl);

  /// The base URL (without trailing '/') for API queries.
  ///
  /// For example: 'https://example.com/api/1.0/oapif/weather'
  final String baseUrl;

  @override
  List<Object?> get props => [baseUrl];
}
