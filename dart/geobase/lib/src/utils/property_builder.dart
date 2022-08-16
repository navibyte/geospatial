// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/vector/content.dart';

/// A builder to create property maps from [PropertyContent] stream.
class PropertyBuilder with PropertyContent {
  final Map<String, dynamic> _map;

  const PropertyBuilder._(this._map);

  /// Builds a property map from the content stream provided by [properties].
  ///
  /// Built property objects are sent into the [to] map (that is also returned).
  static Map<String, dynamic> buildTo(
    WriteProperties properties, {
    required Map<String, dynamic> to,
  }) {
    final builder = PropertyBuilder._(to);
    properties.call(builder);
    return to;
  }

  /// Builds a property map from the content stream provided by [properties].
  static Map<String, dynamic> buildMap(WriteProperties properties) {
    final map = <String, Object?>{};
    final builder = PropertyBuilder._(map);
    properties.call(builder);
    return map;
  }

  @override
  void properties(String name, Map<String, dynamic> map) {
    _map[name] = map;
  }

  @override
  void property(String name, Object? value) {
    _map[name] = value;
  }
}
