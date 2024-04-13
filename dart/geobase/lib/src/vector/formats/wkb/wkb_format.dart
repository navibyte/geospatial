// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:typed_data';

import '/src/common/codes/coords.dart';
import '/src/common/codes/geom.dart';
import '/src/common/reference/coord_ref_sys.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_series.dart';
import '/src/utils/byte_reader.dart';
import '/src/utils/byte_utils.dart';
import '/src/utils/byte_writer.dart';
import '/src/utils/coord_type.dart';
import '/src/utils/format_validation.dart';
import '/src/vector/content/geometry_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/content_decoder.dart';
import '/src/vector/encoding/content_encoder.dart';

part 'wkb_decoder.dart';
part 'wkb_encoder.dart';

/// The flavor (or a variation) of the Well-known binary (WKB) specification.
///
/// This is used when encoding data to the WKB binary representation to specify
/// how bytes are written. However when decoding data a variation is
/// transparently detected without need to specify it.
enum WkbFlavor {
  /// The standard WKB specified by
  /// [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
  standard,

  /// The PostGIS-specific Extended WKB (or EWKB) as documented by
  /// [Well-Known binary from GEOS](https://libgeos.org/specifications/wkb/).
  extended,
}

/// The Well-known binary (WKB) format, see [geometry] for the standard WKB and
/// [geometryExtended] for the Extended WKB (EWKB).
///
/// More information:
/// * [Well-known binary](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary).
/// * [Simple Feature Access - Part 1: Common Architecture](https://www.ogc.org/standards/sfa)
/// * [ISO 13249-3](https://www.iso.org/standard/60343.html)
/// * [Well-Known binary from GEOS](https://libgeos.org/specifications/wkb/)
class WKB {
  /// The Well-known binary (WKB) format for geometries.
  ///
  /// Use `encoder` and `encoder` methods of the format instance to access an
  /// encoder or an decoder for WKB.
  ///
  /// {@template geobase.WKB.geometry.types}
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
  /// {@endtemplate}
  /// {@template geobase.WKB.geometry.endian}
  ///
  /// For WKB binary data encoding, the `Endian.little` (NDR) byte order is used
  /// by default, however when accessing an encoder it's possible to specify
  /// also the `Endian.big` (XDR) byte order.
  ///
  /// {@endtemplate}
  ///
  /// See also [geometryExtended] to get a format for the Extended WKB (EWKB).
  static const BinaryFormat<GeometryContent> geometry =
      _WkbGeometryBinaryFormat(flavor: WkbFlavor.standard);

  /// The Extended WKB (EWKB) format for geometries.
  ///
  /// Use `encoder` and `encoder` methods of the format instance to access an
  /// encoder or an decoder for EWKB.
  ///
  /// {@macro geobase.WKB.geometry.types}
  ///
  /// When encoding EWKB data 2D type codes are used with dimensionalty flags
  /// added as described below.
  ///
  /// Supports also Extended WKB (EWKB) flags on a geometry type:
  /// * 3D coordinates: flag `0x80000000` is set
  /// * Measured coordinates: flag `0x40000000` is set
  /// * CRS known: `0x20000000` is set
  ///
  /// {@macro geobase.WKB.geometry.endian}
  ///
  /// See also [geometry] to get a format for the standard WKB.
  static const BinaryFormat<GeometryContent> geometryExtended =
      _WkbGeometryBinaryFormat(flavor: WkbFlavor.extended);

  /// Decodes a byte order (`Endian.little` or `Endian.big`) from [bytes]
  /// representing standard WKB or Extended WKB (EWKB) data.
  static Endian decodeEndian(Uint8List bytes) {
    if (bytes.isNotEmpty) {
      if (bytes[0] == 0) {
        return Endian.big;
      } else if (bytes[0] == 1) {
        return Endian.little;
      }
    }
    throw const FormatException('not wkb data');
  }

  /// Decodes a byte order (`Endian.little` or `Endian.big`) from [bytesHex] (as
  /// a hex string) representing standard WKB or Extended WKB (EWKB) data.
  static Endian decodeEndianHex(String bytesHex) =>
      decodeEndian(Uint8ListUtils.fromHex(bytesHex));

  /// Decodes a format flavor from [bytes] representing standard WKB or Extended
  /// WKB (EWKB) data.
  static WkbFlavor decodeFlavor(Uint8List bytes) {
    if (bytes.length >= 5) {
      final endian = decodeEndian(bytes);
      if (endian == Endian.big) {
        // big endian -> EWKB flags are on byte 1
        if ((bytes[1]) != 0) {
          return WkbFlavor.extended;
        }
      } else {
        // little endian -> EWKB flags are on byte 4
        if ((bytes[4]) != 0) {
          return WkbFlavor.extended;
        }
      }
      return WkbFlavor.standard;
    }
    throw const FormatException('not wkb data');
  }

  /// Decodes a format flavor from [bytesHex] (as a hex string) representing
  /// standard WKB or Extended WKB (EWKB) data.
  static WkbFlavor decodeFlavorHex(String bytesHex) =>
      decodeFlavor(Uint8ListUtils.fromHex(bytesHex));

  /// Decodes an optional SRID from [bytes] representing Extended WKB (EWKB)
  /// data.
  ///
  /// Returns null if SRID is not available.
  static int? decodeSRID(Uint8List bytes) {
    if (bytes.length >= 5) {
      final endian = decodeEndian(bytes);
      if (endian == Endian.big) {
        // big endian -> SRID flag is on byte 1
        if ((bytes[1] & 0x20) != 0 && bytes.length >= 9) {
          // has SRID on bytes 5 to 8 (most significant first)
          return (bytes[5] << 24) |
              (bytes[6] << 16) |
              (bytes[7] << 8) |
              bytes[8];
        }
      } else {
        // little endian -> SRID flag is on byte 4
        if ((bytes[4] & 0x20) != 0 && bytes.length >= 9) {
          // has SRID on bytes 5 to 8 (most significant last)
          return (bytes[8] << 24) |
              (bytes[7] << 16) |
              (bytes[6] << 8) |
              bytes[5];
        }
      }
    }

    return null; // unknown
  }

  /// Decodes an optional SRID from [bytesHex] (as a hex string) representing
  /// Extended WKB (EWKB) data.
  ///
  /// Returns null if SRID is not available.
  static int? decodeSRIDHex(String bytesHex) =>
      decodeSRID(Uint8ListUtils.fromHex(bytesHex));
}

class _WkbGeometryBinaryFormat with BinaryFormat<GeometryContent> {
  final WkbFlavor flavor;

  const _WkbGeometryBinaryFormat({required this.flavor});

  /// Returns the WKB binary format encoder for geometry content.
  ///
  /// {@macro geobase.BinaryFormat.encoder}
  ///
  /// {@macro geobase.WKB.geometry.types}
  ///
  /// {@macro geobase.WKB.geometry.endian}
  @override
  ContentEncoder<GeometryContent> encoder({
    Endian? endian,
    CoordRefSys? crs,
    Map<String, dynamic>? options, // options ignored for encoding WKB
  }) =>
      _WkbGeometryEncoder(
        // unless nothing specified, WKB data is encoded as Endian.little
        endian: endian ?? Endian.little,

        flavor: flavor,
        crs: crs,
      );

  /// Returns the WKB binary format decoder that decodes bytes as geometry
  /// content to [builder].
  ///
  /// {@macro geobase.BinaryFormat.decoder}
  ///
  /// For the WKB binary data encoding, any [endian] value given is ignored as
  /// an endianess is read from data header fields.
  ///
  /// {@macro geobase.WKB.geometry.types}
  @override
  ContentDecoder decoder(
    GeometryContent builder, {
    Endian? endian,
    CoordRefSys? crs, // a CRS hint ignored for decoding WKB
    Map<String, dynamic>? options, // options ignored for decoding WKB
  }) =>
      // any endian given is ignored, because WKB data has this info on headers
      _WkbGeometryDecoder(builder);
}
