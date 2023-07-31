// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/crs/coord_ref_sys.dart';

import 'content_decoder.dart';
import 'content_encoder.dart';

/// An interface to access text format encoders (writers) for [Content].
// ignore: one_member_abstracts
abstract class TextWriterFormat<Content extends Object> {
  /// Returns a text format encoder for [Content].
  ///
  /// When an optional [buffer] is given, then representations are written into
  /// it (without clearing any content it might already contain).
  ///
  /// After writing content objects into an encoder, the text representation can
  /// be accessed using `toText()` of the encoder (or via [buffer] when such
  /// is given).
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when writing) about coordinate reference system in text output.
  ///
  /// Other format or encoder implementation specific options can be set by
  /// [options].
  ContentEncoder<Content> encoder({
    StringSink? buffer,
    int? decimals,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  });
}

/// An interface to access text format decoders (readers) for [Content].
// ignore: one_member_abstracts
abstract class TextReaderFormat<Content extends Object> {
  /// Returns a text format decoder that decodes text as [Content] to [builder].
  ///
  /// Content decoded by a decoder is sent to a content interface represented
  /// by an object [builder].
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when read in) about coordinate reference system in text input.
  ///
  /// Format or decoder implementation specific options can be set by [options].
  ContentDecoder decoder(
    Content builder, {
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  });
}

/// A mixin to access text format encoders and decoders for [Content].
mixin TextFormat<Content extends Object>
    implements TextWriterFormat<Content>, TextReaderFormat<Content> {}
