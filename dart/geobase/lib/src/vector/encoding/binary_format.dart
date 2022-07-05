// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import 'content_decoder.dart';
import 'content_encoder.dart';

/// A mixin to access binary format encoders and decoders for content of [T].
mixin BinaryFormat<T extends Object> {
  /// Returns a binary format encoder for content of [T].
  ///
  /// [endian] specifies endianness for byte sequences written.
  ///
  /// [bufferSize] suggests the buffer size for writing bytes.
  /// 
  /// After writing content objects into an encoder, the binary representation
  /// can be accessed using `toBytes()` of the encoder.
  ContentEncoder<T> encoder({
    Endian endian = Endian.big,
    int bufferSize = 128,
  });

  /// Returns a binary format decoder decoding content of [T] to [target].
  /// 
  /// Content decoded by a decoder is sent to a content stream interface
  /// represented by [target].
  ///
  /// [endian] specifies endianness for byte sequences read.
  ContentDecoder decoder(
    T target, {
    Endian endian = Endian.big,
  });
}
