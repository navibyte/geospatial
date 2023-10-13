// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import 'package:meta/meta.dart';

import '/src/constants/epsilon.dart';
import '/src/coordinates/base/bounded.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/base/position_scheme.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/reference/coord_ref_sys.dart';
import '/src/vector/content/feature_content.dart';
import '/src/vector/encoding/binary_format.dart';
import '/src/vector/encoding/text_format.dart';
import '/src/vector/formats/geojson/geojson_format.dart';

/// A common base interface for geospatial feature objects (`Feature` and
/// `FeatureCollection`).
///
/// Feature object classes (including all subtypes) are immutable.
@immutable
abstract class FeatureObject extends Bounded {
  final Map<String, dynamic>? _custom;

  /// A feature object with optional [bounds] and [custom] properties.
  const FeatureObject({super.bounds, Map<String, dynamic>? custom})
      : _custom = custom;

  @override
  FeatureObject populated({
    int traverse = 0,
    bool onBounds = true,
    PositionScheme scheme = Position.scheme,
  });

  @override
  FeatureObject unpopulated({
    int traverse = 0,
    bool onBounds = true,
  });

  @override
  FeatureObject project(Projection projection);

  @override
  bool equalsCoords(FeatureObject other);

  @override
  bool equals2D(
    FeatureObject other, {
    double toleranceHoriz = defaultEpsilon,
  });

  @override
  bool equals3D(
    FeatureObject other, {
    double toleranceHoriz = defaultEpsilon,
    double toleranceVert = defaultEpsilon,
  });

  /// Optional custom or "foreign member" properties as a map.
  Map<String, dynamic>? get custom => _custom;

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
