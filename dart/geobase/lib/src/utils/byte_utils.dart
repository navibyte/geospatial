// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Utilities on `Uint8List`.
@internal
extension Uint8ListUtils on Uint8List {
  /// Encode bytes as Hexadecimal (base 16) string.
  String toHex() => map((e) => e.toRadixString(16).padLeft(2, '0')).join();

  /// Decode a hexadecimal (base 16) string in [data] to bytes as `Uint8List`.
  static Uint8List fromHex(String data) {
    final len = data.length;
    if (len.isEven) {
      final byteCount = len ~/ 2;
      final bytes = List.filled(byteCount, 0);
      for (var i = 0; i < byteCount; i++) {
        bytes[i] = int.parse(data.substring(i * 2, i * 2 + 2), radix: 16);
      }
      return Uint8List.fromList(bytes);
    }
    throw FormatException('not valid hex string $data');
  }
}
