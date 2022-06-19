// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

/// A writer (integer and floating point values) writing a sequence of bytes.
///
/// The [ByteWriter] class is (at least currently) an internal utility class.
class ByteWriter {
  final Endian _endian;

  /// A writer (integer and floating point values) writing a sequence of bytes.
  /// 
  /// A writer should be buffered, but it's implementation strategies are not
  /// specified.
  ///
  /// [endian] specifies endianness to be used when writing a sequence of bytes.
  ByteWriter.buffered({Endian endian = Endian.big}) : _endian = endian;

  /// Collects the data written to a sequence of bytes in a Uint8List.
  Uint8List toBytes() {
    return Uint8List(0); // todo
  }

  /// Writes [value] as four bytes (IEEE 754 single-precision floating-point).
  ///
  /// See `ByteData.setFloat32` from `dart:typed_data` for reference.
  void writeFloat32(double value) {
    // todo
  }

  /// Writes [value] as eight bytes (IEEE 754 double-precision floating-point).
  ///
  /// See `ByteData.setFloat64` from `dart:typed_data` for reference.
  void writeFloat64(double value) {
    // todo
  }

  /// Writes [value] as a single byte (two's complement binary representation).
  ///
  /// See `ByteData.setInt8` from `dart:typed_data` for reference.
  void writeInt8(int value) {
    // todo
  }

  /// Writes [value] as two bytes (two's complement binary representation).
  ///
  /// See `ByteData.setInt16` from `dart:typed_data` for reference.
  void writeInt16(int value) {
    // todo
  }

  /// Writes [value] as four bytes (two's complement binary representation).
  ///
  /// See `ByteData.setInt32` from `dart:typed_data` for reference.
  void writeInt32(int value) {
    // todo
  }

  /// Writes [value] as eight bytes (two's complement binary representation).
  ///
  /// See `ByteData.setInt64` from `dart:typed_data` for reference.
  void writeInt64(int value) {
    // todo
  }

  /// Writes [value] as a single byte (unsigned binary representation).
  ///
  /// See `ByteData.setUint8` from `dart:typed_data` for reference.
  void writeUint8(int value) {
    // todo
  }

  /// Writes [value] as two bytes (unsigned binary representation).
  ///
  /// See `ByteData.setUint16` from `dart:typed_data` for reference.
  void writeUint16(int value) {
    // todo
  }

  /// Writes [value] as four bytes (unsigned binary representation).
  ///
  /// See `ByteData.setUint32` from `dart:typed_data` for reference.
  void writeUint32(int value) {
    // todo
  }

  /// Writes [value] as eight bytes (unsigned binary representation).
  ///
  /// See `ByteData.setUint64` from `dart:typed_data` for reference.
  void writeUint64(int value) {
    // todo
  }
}
