// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/vector/encoding.dart';

/// A factory function to create [ContentEncoder] for [Content].
typedef CreateTextEncoder<Content extends Object> = ContentEncoder<Content>
    Function({
  StringSink? buffer,
  int? decimals,
});

/// A helper implementation of [TextWriterFormat] for [Content].
class TextWriterFormatImpl<Content extends Object>
    with TextWriterFormat<Content> {
  /// A helper implementation of [TextWriterFormat] for [Content].
  const TextWriterFormatImpl(this.factory);

  /// A factory function to create [ContentEncoder] for [Content].
  final CreateTextEncoder<Content> factory;

  @override
  ContentEncoder<Content> encoder({
    StringSink? buffer,
    int? decimals,
  }) =>
      factory.call(buffer: buffer, decimals: decimals);
}

/// A factory function to create [ContentEncoder] for [Content] with [Conf].
typedef CreateTextEncoderConf<Content extends Object, Conf extends Object>
    = ContentEncoder<Content> Function({
  StringSink? buffer,
  int? decimals,
  Conf? conf,
});

/// A helper implementation of [TextWriterFormat] for [Content] with [Conf].
class TextWriterFormatImplConf<Content extends Object, Conf extends Object>
    with TextWriterFormat<Content> {
  /// A helper implementation of [TextWriterFormat] for [Content] with [Conf].
  const TextWriterFormatImplConf(this.factory, {this.conf});

  /// A factory function to create [ContentEncoder] for [Content] with [Conf].
  final CreateTextEncoderConf<Content, Conf> factory;

  /// Optional configuration.
  final Conf? conf;

  @override
  ContentEncoder<Content> encoder({
    StringSink? buffer,
    int? decimals,
  }) =>
      factory.call(
        buffer: buffer,
        decimals: decimals,
        conf: conf,
      );
}
