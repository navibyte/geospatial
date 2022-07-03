// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

/// An interface to write content of [T] into a content format (text or binary).
abstract class ContentWriter<T extends Object> {
  /// The content [output] interface that is used by a client to write content.
  T get output;

  /// The text representation of content already written to this writer.
  ///
  /// Returns a valid string representation of content for a text format writer
  /// and a base64 string representation of content for a binary format writer.
  @override
  String toString();

  /// The binary representation of content already written to this writer.
  ///
  /// Returns a valid binary representation of content as a sequence of bytes
  /// for a binary format writer, and an UTF8 encoded binary representation of
  /// textual content for a text format writer.
  Uint8List toBytes();
}
