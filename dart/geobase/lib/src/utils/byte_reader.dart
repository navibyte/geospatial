// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

/// A reader (integer and floating point values) reading a sequence of bytes.
///
/// The [ByteReader] class is (at least currently) an internal utility class.
class ByteReader {
  final ByteBuffer _buffer;
  final Endian _endian;

  /// A reader (integer and floating point values) reading a view of [buffer].
  ///
  /// [endian] specifies endianness to be used when reading a sequence of bytes.
  ByteReader.view(ByteBuffer buffer, {Endian endian = Endian.big})
      : _buffer = buffer,
        _endian = endian;

  /// Resets a reader to position a cursor to the start of a sequence of bytes.
  void reset() {
    // todo
  }

  /// Reads a value from four bytes (IEEE 754 single-precision floating-point).
  ///
  /// See `ByteData.getFloat32` from `dart:typed_data` for reference.
  double readFloat32() {
    return 0; // todo
  }

  /// Reads a value from eight bytes (IEEE 754 double-precision floating-point).
  ///
  /// See `ByteData.getFloat64` from `dart:typed_data` for reference.
  double readFloat64() {
    return 0; // todo
  }

  /// Reads a value from a single byte (two's complement binary representation).
  ///
  /// See `ByteData.getInt8` from `dart:typed_data` for reference.
  int readInt8() {
    return 0; // todo
  }

  /// Reads a value from two bytes (two's complement binary representation).
  ///
  /// See `ByteData.getInt16` from `dart:typed_data` for reference.
  int readInt16() {
    return 0; // todo
  }

  /// Reads a value from four bytes (two's complement binary representation).
  ///
  /// See `ByteData.getInt32` from `dart:typed_data` for reference.
  int readInt32() {
    return 0; // todo
  }

  /// Reads a value from eight bytes (two's complement binary representation).
  ///
  /// See `ByteData.getInt64` from `dart:typed_data` for reference.
  int readInt64() {
    return 0; // todo
  }

  /// Reads a value from a single byte (unsigned binary representation).
  ///
  /// See `ByteData.getUint8` from `dart:typed_data` for reference.
  int readUint8() {
    return 0; // todo
  }

  /// Reads a value from two bytes (unsigned binary representation).
  ///
  /// See `ByteData.getUint16` from `dart:typed_data` for reference.
  int readUint16() {
    return 0; // todo
  }

  /// Reads a value from four bytes (unsigned binary representation).
  ///
  /// See `ByteData.getUint32` from `dart:typed_data` for reference.
  int readUint32() {
    return 0; // todo
  }

  /// Reads a value from eight bytes (unsigned binary representation).
  ///
  /// See `ByteData.getUint64` from `dart:typed_data` for reference.
  int readUint64() {
    return 0; // todo
  }
}
