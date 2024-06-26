// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';

import 'package:meta/meta.dart';

import '/src/common/service/service_exception.dart';
import '/src/core/features/feature_failure.dart';

/// Maps a JSON Object read from [source] to an entity using [toEntity].
///
/// The source function returns a future that fetches data from a file, a web
/// resource or other sources. Content must be GeoJSON compliant data.
@internal
Future<T> readEntityFromJsonObject<T>(
  Future<String> Function() source, {
  required T Function(Map<String, dynamic> data) toEntity,
}) async {
  try {
    // read content as text
    final text = await source();

    // decode JSON and expect a JSON Object as `Map<String, dynamic>`
    final data = json.decode(text) as Map<String, dynamic>;

    // map JSON Object to an entity
    return toEntity(data);
  } on ServiceException<FeatureFailure> {
    rethrow;
  } catch (e, st) {
    // other exceptions (including errors)
    throw ServiceException(FeatureFailure.clientError, cause: e, trace: st);
  }
}

/// Maps text data read from [source] to an entity using [toEntity].
///
/// The source function returns a future that fetches data from a file, a web
/// resource or other sources. Content must be GeoJSON compliant data.
@internal
Future<T> readEntityFromText<T>(
  Future<String> Function() source, {
  required T Function(String text) toEntity,
}) async {
  try {
    // read content as text
    final text = await source();

    // map text to an entity
    return toEntity(text);
  } on ServiceException<FeatureFailure> {
    rethrow;
  } catch (e, st) {
    // other exceptions (including errors)
    throw ServiceException(FeatureFailure.clientError, cause: e, trace: st);
  }
}
