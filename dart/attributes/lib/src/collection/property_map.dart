// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import 'value_accessor.dart';
import 'value_accessor_mixin.dart';

/// A property map implements [ValueAccessor] interface for property access.
abstract class PropertyMap implements ValueAccessor<String> {
  const PropertyMap();

  /// Create an [PropertyMap] instance backed by [source].
  factory PropertyMap.view(Map<String, dynamic> source) = _WrappedPropertyMap;

  /// Create an immutable [PropertyMap] with items copied from [source].
  factory PropertyMap.from(Map<String, dynamic> source) =>
      _WrappedPropertyMap(Map.from(source));

  /// Creates an empty [PropertyMap].
  factory PropertyMap.empty() => const _WrappedPropertyMap({});

  /// Returns properties or key-value pairs as a [map], allowed to be empty.
  Map<String, dynamic> get map;
}

/// Private implementation of [PropertyMap].
/// The implementation may change in future.
@immutable
class _WrappedPropertyMap extends PropertyMap
    with ValueAccessorMixin<String>, EquatableMixin {
  const _WrappedPropertyMap(this.map);

  @override
  final Map<String, dynamic> map;

  @override
  List<Object?> get props => [map];

  @override
  int get length => map.length;

  @override
  Iterable<String> get keys => map.keys;

  @override
  dynamic operator [](String key) => map[key];
}
