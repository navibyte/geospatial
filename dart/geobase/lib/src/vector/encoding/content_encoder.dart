// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

/// An interface to encode some content of [T] into a text or binary format.
abstract class ContentEncoder<T extends Object> {
  /// Returns the writer used by a client to write content to this encoder.
  ///
  /// Calling this property never throws, but methods provided by the [T]
  /// interface (that are used to write content) should throw `FormatException`
  /// if writing / encoding fails.
  T get writer;

  /// The binary representation of content already written to this encoder.
  ///
  /// Returns a valid binary representation of content as a sequence of bytes
  /// for a binary format encoder, and an UTF8 encoded binary representation of
  /// textual content for a text format encoder.
  ///
  /// Throws `FormatException` if encoding fails.
  Uint8List toBytes();

  /// The text representation of content already written to this encoder.
  ///
  /// Returns a valid string representation of content for a text format encoder
  /// and a base64 string representation of content for a binary format encoder.
  ///
  /// Throws `FormatException` if encoding fails.
  String toText();

  /// The text representation of content already written to this encoder.
  /// 
  /// Equals to calling [toText].
  ///
  /// Returns a valid string representation of content for a text format encoder
  /// and a base64 string representation of content for a binary format encoder.
  ///
  /// Throws `FormatException` if encoding fails.
  @override
  String toString();
}
