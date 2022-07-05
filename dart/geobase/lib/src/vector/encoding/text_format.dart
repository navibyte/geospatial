// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'content_encoder.dart';

/// A mixin to access text format encoders for content of [T].
mixin TextFormat<T extends Object> {
  /// Returns a text format encoder for content of [T].
  ///
  /// When an optional [buffer] is given, then representations are written into
  /// it (without clearing any content it might already contain).
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// After writing content objects into an encoder, the text representation can
  /// be accessed using `toText()` of the encoder (or via [buffer] when such
  /// is given).
  ContentEncoder<T> encoder({
    StringSink? buffer,
    int? decimals,
  });
}
