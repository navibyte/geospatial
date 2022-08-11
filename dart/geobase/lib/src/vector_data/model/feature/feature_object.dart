// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/vector/content.dart';
import '/src/vector/encoding.dart';
import '/src/vector/formats.dart';
import '/src/vector_data/model/bounded.dart';

/// A common base interface for geospatial feature objects (`Feature` and
/// `FeatureCollection`).
@immutable
abstract class FeatureObject extends Bounded {
  /// Default `const` constructor to allow extending this abstract class.
  const FeatureObject();

  /// Writes this feature object to [writer].
  void writeTo(FeatureContent writer);

  /// The string representation of this feature object, with [format] applied.
  ///
  /// When [format] is not given, then [GeoJSON] is used as a default.
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  String toStringAs({
    TextWriterFormat<FeatureContent> format = GeoJSON.feature,
    int? decimals,
  }) {
    final encoder = format.encoder(decimals: decimals);
    writeTo(encoder.writer);
    return encoder.toText();
  }

  /// The string representation of this feature object as specified by
  /// [GeoJSON].
  @override
  String toString() => toStringAs();
}
