// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:typed_data';

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/coordinates/base.dart';
import '/src/utils/byte_writer.dart';
import '/src/utils/format_validation.dart';
import '/src/vector/content.dart';
import '/src/vector/encode.dart';

part 'wkb_writer.dart';

/// The Well-known binary (WKB) format for geometries.
///
/// The Well-known binary (WKB) format is defined by:
/// [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
/// standard by [The Open Geospatial Consortium](https://www.ogc.org/).
///
/// Supported geometry types and their "WKB integer codes" for different
/// coordinate types:
///
/// Geometry             | 2D   | Z    | M    | ZM
/// -------------------- | ---- | ---- | ---- | ----
/// `point`              | 0001 | 1001 | 2001 | 3001
/// `lineString`         | 0002 | 1002 | 2002 | 3002
/// `polygon`            | 0003 | 1003 | 2003 | 3003
/// `multiPoint`         | 0004 | 1004 | 2004 | 3004
/// `multiLineString`    | 0005 | 1005 | 2005 | 3005
/// `multiPolygon`       | 0006 | 1006 | 2006 | 3006
/// `geometryCollection` | 0007 | 1007 | 2007 | 3007
///
/// More information:
/// [Well-known binary](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary).
class WKB {
  /// The Well-known binary (WKB) format for geometries.
  WKB();

  /// Returns a writer formatting geometry objects as the WKB binary format.
  ///
  /// After writing some objects with coordinate data into a writer, the binary
  /// representation can be accessed using `toBytes()` of it.
  ContentWriter<GeometryContent> encoder({
    Endian endian = Endian.big,
    int bufferSize = 128,
  }) =>
      _WkbGeometryWriter(
        ByteWriter.buffered(
          endian: endian,
          bufferSize: bufferSize,
        ),
      );

  /// Writes [geometries] to a sequence of bytes as specified by the WKB format.
  Uint8List encode(WriteGeometries geometries) {
    final w = encoder();
    geometries.call(w.output);
    return w.toBytes();
  }
}
