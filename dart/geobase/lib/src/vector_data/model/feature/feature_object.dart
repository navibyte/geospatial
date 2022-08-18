// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/coordinates/projection.dart';
import '/src/vector/content.dart';
import '/src/vector/encoding.dart';
import '/src/vector/formats.dart';
import '/src/vector_data/model/bounded.dart';

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
  /// When [format] is not given, then [GeoJSON] is used as a default.
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  String toText({
    TextWriterFormat<FeatureContent> format = GeoJSON.feature,
    int? decimals,
  }) {
    final encoder = format.encoder(decimals: decimals);
    writeTo(encoder.writer);
    return encoder.toText();
  }

  /// The string representation of this feature object as specified by
  /// [GeoJSON].
  ///
  /// See also [toText].
  @override
  String toString() => toText();
}
