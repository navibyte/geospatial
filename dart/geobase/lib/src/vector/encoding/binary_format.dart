// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import '/src/common/reference/coord_ref_sys.dart';

import 'content_decoder.dart';
import 'content_encoder.dart';

/// A mixin to access binary format encoders and decoders for [Content]
mixin BinaryFormat<Content extends Object> {
  /// Returns a binary format encoder for [Content].
  ///
  /// {@template geobase.BinaryFormat.encoder}
  ///
  /// After writing content objects into an encoder, the binary representation
  /// can be accessed using `toBytes()` of the encoder.
  ///
  /// An optional [endian] specifies endianness for byte sequences written. Some
  /// encoders might ignore this, and some has a default value for it.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when writing) about coordinate reference system in binary
  /// output. When data itself have CRS information it overrides this value.
  ///
  /// Other format or encoder implementation specific options can be set by
  /// [options].
  ///
  /// {@endtemplate}
  ContentEncoder<Content> encoder({
    Endian? endian,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  });

  /// Returns a binary format decoder that decodes bytes as [Content] to
  /// [builder].
  ///
  /// {@template geobase.BinaryFormat.decoder}
  ///
  /// Content decoded by a decoder is sent to a content interface represented
  /// by an object [builder].
  ///
  /// An optional [endian] specifies endianness for byte sequences read. Some
  /// decoders might ignore this, and some resolve it by reading data to be
  /// decoded.
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when writing) about coordinate reference system in binary
  /// output. When data itself have CRS information it overrides this value.
  ///
  /// Other format or decoder implementation specific options can be set by
  /// [options].
  ///
  /// {@endtemplate}
  ContentDecoder decoder(
    Content builder, {
    Endian? endian,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  });
}
