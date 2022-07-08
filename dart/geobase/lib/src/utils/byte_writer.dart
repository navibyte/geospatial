// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import 'dart:typed_data';

/// A writer (integer and floating point values) writing a sequence of bytes.
///
/// The [ByteWriter] class is (at least currently) an internal utility class.
class ByteWriter {
  final _ChunkedByteBuffer _buffer;
  ByteData _chunk;
  int _offset = 0;
  bool _needNewChunk = false;

  /// The endianness for byte sequences written.
  final Endian endian;

  /// The buffer size for writing bytes.
  final int bufferSize;

  /// Whether to encode `double.nan` as `-double.nan` on byte data.
  /// 
  /// This is applied only by [writeFloat32] and [writeFloat64] methods.
  final bool nanEncodedAsNegative;

  /// A writer (integer and floating point values) writing a sequence of bytes.
  ///
  /// A writer should be buffered, but it's implementation strategies are not
  /// specified.
  ///
  /// [endian] specifies endianness for byte sequences written.
  ///
  /// [bufferSize] suggests the buffer size for writing bytes.
  ByteWriter.buffered({
    this.endian = Endian.big,
    this.bufferSize = 128,
    this.nanEncodedAsNegative = false,
  })  : _buffer = _ChunkedByteBuffer(),
        _chunk = ByteData(bufferSize);

  void _reserve(int len) {
    if (_needNewChunk) {
      _chunk = ByteData(math.max(bufferSize, len));
      _offset = 0;
      _needNewChunk = false;
    } else {
      if (_offset + len > bufferSize) {
        _flush();
        _chunk = ByteData(math.max(bufferSize, len));
        _offset = 0;
        _needNewChunk = false;
      }
    }
  }

  void _flush() {
    if (_offset > 0) {
      _buffer.addBytes(_chunk.buffer.asUint8List(0, _offset));
      _needNewChunk = true;
    }
  }

  /// Collects the data written to a sequence of bytes in a Uint8List.
  Uint8List toBytes() {
    _flush();
    return _buffer.toBytes();
  }

  /// Writes [value] as four bytes (IEEE 754 single-precision floating-point).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.setFloat32` from `dart:typed_data` for reference.
  /// 
  /// See also configuration parameter [nanEncodedAsNegative].
  void writeFloat32(double value, [Endian? endian]) {
    _reserve(4);
    _chunk.setFloat32(
      _offset,
      nanEncodedAsNegative && value.isNaN ? -double.nan : value,
      endian ?? this.endian,
    );
    _offset += 4;
  }

  /// Writes [value] as eight bytes (IEEE 754 double-precision floating-point).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.setFloat64` from `dart:typed_data` for reference.
  /// 
  /// See also configuration parameter [nanEncodedAsNegative].
  void writeFloat64(double value, [Endian? endian]) {
    _reserve(8);
    _chunk.setFloat64(
      _offset,
      nanEncodedAsNegative && value.isNaN ? -double.nan : value,
      endian ?? this.endian,
    );
    _offset += 8;
  }

  /// Writes [value] as a single byte (two's complement binary representation).
  ///
  /// See `ByteData.setInt8` from `dart:typed_data` for reference.
  void writeInt8(int value) {
    _reserve(1);
    _chunk.setInt8(_offset, value);
    _offset += 1;
  }

  /// Writes [value] as two bytes (two's complement binary representation).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.setInt16` from `dart:typed_data` for reference.
  void writeInt16(int value, [Endian? endian]) {
    _reserve(2);
    _chunk.setInt16(_offset, value, endian ?? this.endian);
    _offset += 2;
  }

  /// Writes [value] as four bytes (two's complement binary representation).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.setInt32` from `dart:typed_data` for reference.
  void writeInt32(int value, [Endian? endian]) {
    _reserve(4);
    _chunk.setInt32(_offset, value, endian ?? this.endian);
    _offset += 4;
  }

  /// Writes [value] as eight bytes (two's complement binary representation).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.setInt64` from `dart:typed_data` for reference.
  void writeInt64(int value, [Endian? endian]) {
    _reserve(8);
    _chunk.setInt64(_offset, value, endian ?? this.endian);
    _offset += 8;
  }

  /// Writes [value] as a single byte (unsigned binary representation).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.setUint8` from `dart:typed_data` for reference.
  void writeUint8(int value) {
    _reserve(1);
    _chunk.setUint8(_offset, value);
    _offset += 1;
  }

  /// Writes [value] as two bytes (unsigned binary representation).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.setUint16` from `dart:typed_data` for reference.
  void writeUint16(int value, [Endian? endian]) {
    _reserve(2);
    _chunk.setUint16(_offset, value, endian ?? this.endian);
    _offset += 2;
  }

  /// Writes [value] as four bytes (unsigned binary representation).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.setUint32` from `dart:typed_data` for reference.
  void writeUint32(int value, [Endian? endian]) {
    _reserve(4);
    _chunk.setUint32(_offset, value, endian ?? this.endian);
    _offset += 4;
  }

  /// Writes [value] as eight bytes (unsigned binary representation).
  ///
  /// Uses the parameter [endian] if non-null, otherwise uses `this.endian`.
  ///
  /// See `ByteData.setUint64` from `dart:typed_data` for reference.
  void writeUint64(int value, [Endian? endian]) {
    _reserve(8);
    _chunk.setUint64(_offset, value, endian ?? this.endian);
    _offset += 8;
  }
}

class _ChunkedByteBuffer {
  final List<Uint8List> _chunks;
  var _length = 0;

  _ChunkedByteBuffer() : _chunks = <Uint8List>[];

  void addBytes(Uint8List bytes) {
    _chunks.add(bytes);
    _length += bytes.length;
  }

  Uint8List toBytes() {
    if (_chunks.length == 1) {
      return _chunks.first.sublist(0, _length);
    } else {
      final buf = Uint8List(_length);
      var start = 0;
      for (final chunk in _chunks) {
        buf.setRange(start, start + chunk.length, chunk);
        start += chunk.length;
      }
      return buf;
    }
  }
}
