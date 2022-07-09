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
import '/src/utils/byte_reader.dart';
import '/src/utils/byte_writer.dart';
import '/src/utils/format_validation.dart';
import '/src/vector/content.dart';
import '/src/vector/encoding.dart';

import 'wkb_conf.dart';

part 'wkb_decoder.dart';
part 'wkb_encoder.dart';

/// The Well-known binary (WKB) format, see [geometry] for accessing the format.
///
/// More information:
/// * [Well-known binary](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary).
/// * [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
/// * [ISO 13249-3](https://www.iso.org/standard/60343.html)
/// * [Well-Known binary from GEOS](https://libgeos.org/specifications/wkb/)
class WKB {
  /// The Well-known binary (WKB) format for geometries.
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
  static const BinaryFormat<GeometryContent> geometry =
      _WkbGeometryBinaryFormat();

  /// The Well-known binary (WKB) format for geometries with optional [conf].
  /// 
  /// See [geometry] for more information about supported geometry types.
  static BinaryFormat<GeometryContent> geometryFormat([WkbConf? conf]) =>
      _WkbGeometryBinaryFormat(conf);
}

class _WkbGeometryBinaryFormat with BinaryFormat<GeometryContent> {
  const _WkbGeometryBinaryFormat([this.conf]);

  final WkbConf? conf;

  @override
  ContentEncoder<GeometryContent> encoder({
    Endian endian = Endian.big,
    int bufferSize = 128,
  }) =>
      _WkbGeometryEncoder(endian: endian, bufferSize: bufferSize, conf: conf);

  @override
  ContentDecoder decoder(
    GeometryContent builder, {
    Endian endian = Endian.big,
  }) =>
      _WkbGeometryDecoder(builder, endian: endian, conf: conf);
}
