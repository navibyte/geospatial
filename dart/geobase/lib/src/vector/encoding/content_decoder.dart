// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

/// An interface to decode content from a text or binary format.
abstract class ContentDecoder {
  /// Decodes text from [source] as content objects.
  ///
  /// The [source] text is expected to be a valid string representation of
  /// content for a text format decoder and and a base64 string representation
  /// of content for a binary format decoder.
  /// 
  /// The target of objects decoded from text is not defined by this interface.
  /// A decoder could produce content stream sent to a content interface or
  /// build structured data objects with compatible model. Also some decoders
  /// might allow multiple calls to this method to build a larger target object
  /// structure.
  /// 
  /// Throws `FormatException` if decoding fails.
  void decodeText(String source);

  /// Decodes bytes from [source] as content objects.
  ///
  /// The [source] as a sequence of bytes is expected to be a valid binary
  /// representation of content for a binary format decoder, and an UTF8 encoded
  /// binary representation of textual content for a text format decoder.
  /// 
  /// The target of objects decoded from bytes is not defined by this interface.
  /// A decoder could produce content stream sent to a content interface or
  /// build structured data objects with compatible model. Also some decoders
  /// might allow multiple calls to this method to build a larger target object
  /// structure.
  /// 
  /// Throws `FormatException` if decoding fails.
  void decodeBytes(ByteBuffer source);
}
