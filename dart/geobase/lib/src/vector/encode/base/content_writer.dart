// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An interface to write content of [T] into some content format.
abstract class ContentWriter<T extends Object> {
  /// The content [output] interface that is used by a client to write content.
  T get output;

  /// A string representation of content already written to this (text) writer.
  ///
  /// Must return a valid string representation when this writer is writing to
  /// a text output. If an output does not support a string representation then
  /// returned representation is undefined.
  @override
  String toString();
}
