// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import 'package:meta/meta.dart';

import '/src/coordinates/crs/coord_ref_sys.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/vector/content/feature_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';
import '/src/vector_data/model/bounded/bounded.dart';

/// A common base interface for geospatial feature objects (`Feature` and
/// `FeatureCollection`).
@immutable
abstract class FeatureObject extends Bounded {
  /// A feature object with an optional [bounds].
  const FeatureObject({super.bounds});

  /// Returns a new feature obect with all geometries projected using
  /// [projection].
  ///
  /// The returned feature object sub type must be the same as the type of this.
  ///
  /// Any custom data or properties (other than geometries) are not projected,
  /// just copied (by references).
  ///
  /// Note that any available [bounds] object on this is not projected (that is
  /// the bounds for a returned feature object is null).
  @override
  FeatureObject project(Projection projection);

  /// Optional custom or "foreign member" properties as a map.
  Map<String, dynamic>? get custom => null;

  /// Writes this feature object to [writer].
  void writeTo(FeatureContent writer);

  /// The string representation of this feature object, with [format] applied.
  ///
  /// When [format] is not given, then the feature format of [GeoJSON] is used
  /// as a default.
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// Use [crs] to give hints (like axis order, and whether x and y must
  /// be swapped when writing) about coordinate reference system in text output.
  ///
  /// Other format or encoder implementation specific options can be set by
  /// [options].
  String toText({
    TextWriterFormat<FeatureContent> format = GeoJSON.feature,
    int? decimals,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) {
    final encoder =
        format.encoder(decimals: decimals, crs: crs, options: options);
    writeTo(encoder.writer);
    return encoder.toText();
  }

  /// The binary representation of this feature object, with [format] applied.
  ///
  /// An optional [endian] specifies endianness for byte sequences written. Some
  /// encoders might ignore this, and some has a default value for it.
  ///
  /// Other format or encoder implementation specific options can be set by
  /// [options].
  Uint8List toBytes({
    required BinaryFormat<FeatureContent> format,
    Endian? endian,
    Map<String, dynamic>? options,
  }) {
    final encoder = format.encoder(endian: endian, options: options);
    writeTo(encoder.writer);
    return encoder.toBytes();
  }

  /// The string representation of this feature object as specified by
  /// [GeoJSON].
  ///
  /// See also [toText].
  @override
  String toString() => toText();
}
