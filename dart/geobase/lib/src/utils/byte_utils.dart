// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
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
}
