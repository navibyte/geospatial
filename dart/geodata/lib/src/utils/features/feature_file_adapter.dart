// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:io' show File;

import '/src/core/features.dart';

/// Maps a JSON Object read from [location] to an entity using [toEntity].
Future<T> readEntityFromJsonObject<T>(
  File location, {
  required T Function(Map<String, Object?> data) toEntity,
}) async {
  try {
    // ensure a file exists
    if (!location.existsSync()) {
      throw const FeatureException(FeatureFailure.notFound);
    }

    // read file contents as text
    final text = await location.readAsString();

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
