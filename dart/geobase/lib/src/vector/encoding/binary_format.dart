// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import 'content_decoder.dart';
import 'content_encoder.dart';

/// A mixin to access binary format encoders and decoders for [Content]
mixin BinaryFormat<Content extends Object> {
  /// Returns a binary format encoder for [Content].
  ///
  /// After writing content objects into an encoder, the binary representation
  /// can be accessed using `toBytes()` of the encoder.
  ///
  /// An optional [endian] specifies endianness for byte sequences written. Some
  /// encoders might ignore this, and some has a default value for it.
  ///
  /// Other format or encoder implementation specific options can be set by
  /// [options].
  ContentEncoder<Content> encoder({
    Endian? endian,
    Map<String, dynamic>? options,
  });

  /// Returns a binary format decoder that decodes bytes as [Content] to
  /// [builder].
  ///
  /// Content decoded by a decoder is sent to a content interface represented
  /// by an object [builder].
  ///
  /// An optional [endian] specifies endianness for byte sequences read. Some
  /// decoders might ignore this, and some resolve it by reading data to be
  /// decoded.
  ///
  /// Other format or decoder implementation specific options can be set by
  /// [options].
  ContentDecoder decoder(
    Content builder, {
    Endian? endian,
    Map<String, dynamic>? options,
  });
}
