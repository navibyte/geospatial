// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A reader (integer and floating point values) reading a sequence of bytes.
///
/// The [ByteReader] class is (at least currently) an internal utility class.
@internal
class ByteReader {
  final ByteData _data;
  int _offset = 0;

  /// The endianness for byte sequences read.
  final Endian endian;

  /// A reader (integer and floating point values) reading a view of [buffer].
  ///
  /// [endian] specifies endianness for byte sequences read.
  ByteReader.view(
    ByteBuffer buffer, {
    this.endian = Endian.big,
  }) : _data = buffer.asByteData();

  /// Expect this reader to contain at least [length] bytes left to read.
  ///
  /// Throws FormatException if there are less than [length] bytes left.
  void expect(int length) {
    if (_offset + length > _data.lengthInBytes) {
      throw const FormatException('Buffer limits exceeded');
    }
  }

  /// Returns true if this reader contains bytes available to read.
  bool get hasAvailable => _offset < _data.lengthInBytes;

  /// Reads a value from four bytes (IEEE 754 single-precision floating-point).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.getFloat32` from `dart:typed_data` for reference.
  double readFloat32([Endian? endian]) {
    expect(4);
    final value = _data.getFloat32(_offset, endian ?? this.endian);
    _offset += 4;
    return value;
  }

  /// Reads a value from eight bytes (IEEE 754 double-precision floating-point).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.getFloat64` from `dart:typed_data` for reference.
  double readFloat64([Endian? endian]) {
    expect(8);
    final value = _data.getFloat64(_offset, endian ?? this.endian);
    _offset += 8;
    return value;
  }

  /// Reads a value from a single byte (two's complement binary representation).
  ///
  /// See `ByteData.getInt8` from `dart:typed_data` for reference.
  int readInt8() {
    expect(1);
    final value = _data.getInt8(_offset);
    _offset += 1;
    return value;
  }

  /// Reads a value from two bytes (two's complement binary representation).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.getInt16` from `dart:typed_data` for reference.
  int readInt16([Endian? endian]) {
    expect(2);
    final value = _data.getInt16(_offset, endian ?? this.endian);
    _offset += 2;
    return value;
  }

  /// Reads a value from four bytes (two's complement binary representation).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.getInt32` from `dart:typed_data` for reference.
  int readInt32([Endian? endian]) {
    expect(4);
    final value = _data.getInt32(_offset, endian ?? this.endian);
    _offset += 4;
    return value;
  }

  /// Reads a value from eight bytes (two's complement binary representation).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.getInt64` from `dart:typed_data` for reference.
  int readInt64([Endian? endian]) {
    expect(8);
    final value = _data.getInt64(_offset, endian ?? this.endian);
    _offset += 8;
    return value;
  }

  /// Reads a value from a single byte (unsigned binary representation).
  ///
  /// See `ByteData.getUint8` from `dart:typed_data` for reference.
  int readUint8() {
    expect(1);
    final value = _data.getUint8(_offset);
    _offset += 1;
    return value;
  }

  /// Reads a value from two bytes (unsigned binary representation).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.getUint16` from `dart:typed_data` for reference.
  int readUint16([Endian? endian]) {
    expect(2);
    final value = _data.getUint16(_offset, endian ?? this.endian);
    _offset += 2;
    return value;
  }

  /// Reads a value from four bytes (unsigned binary representation).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.getUint32` from `dart:typed_data` for reference.
  int readUint32([Endian? endian]) {
    expect(4);
    final value = _data.getUint32(_offset, endian ?? this.endian);
    _offset += 4;
    return value;
  }

  /// Reads a value from eight bytes (unsigned binary representation).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.getUint64` from `dart:typed_data` for reference.
  int readUint64([Endian? endian]) {
    expect(8);
    final value = _data.getUint64(_offset, endian ?? this.endian);
    _offset += 8;
    return value;
  }
}
