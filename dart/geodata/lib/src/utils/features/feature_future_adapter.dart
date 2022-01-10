// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';

import '/src/core/features.dart';

/// Maps a JSON Object read from [source] to an entity using [toEntity].
///
/// The source function returns a future that fetches data from a file, a web
/// resource or other sources. Contents must be GeoJSON compliant data.
Future<T> readEntityFromJsonObject<T>(
  Future<String> Function() source, {
  required T Function(Map<String, Object?> data) toEntity,
}) async {
  try {
    // read contents as text
    final text = await source();

    // decode JSON and expect it to contain JSON Object as `Map<String, Object?`
    final data = json.decode(text) as Map<String, Object?>;

    // map JSON Object to an entity
    return toEntity(data);
  } on FeatureException {
    rethrow;
  } catch (e, st) {
    // other exceptions (including errors)
    throw FeatureException(FeatureFailure.clientError, cause: e, trace: st);
  }
}
