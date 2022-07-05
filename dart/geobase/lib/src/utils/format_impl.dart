// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/vector/encoding.dart';

/// A factory function to create [ContentEncoder] for content of [T].
typedef CreateTextEncoder<T extends Object> = ContentEncoder<T> Function({
  StringSink? buffer,
  int? decimals,
});

/// A helper implementation of [TextFormat] for content of [T].
class TextFormatImpl<T extends Object> with TextFormat<T> {
  /// A helper implementation of [TextFormat] for content of [T].
  const TextFormatImpl(this.factory);

  /// A factory function to create [ContentEncoder] for content of [T].
  final CreateTextEncoder<T> factory;

  @override
  ContentEncoder<T> encoder({
    StringSink? buffer,
    int? decimals,
  }) =>
      factory.call(buffer: buffer, decimals: decimals);
}
