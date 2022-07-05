// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/vector.dart';

/// An interface defining the capability to write feature objects.
abstract class FeatureWritable {
  /// Default `const` constructor to allow extending this abstract class.
  const FeatureWritable();

  /// Writes this feature object to [output].
  void writeTo(FeatureContent output);

  /// A string representation of this object, with an optional [format] applied.
  ///
  /// When [format] is not given, then [GeoJSON] is used.
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  String toStringAs({
    TextFormat<FeatureContent> format = GeoJSON.feature,
    int? decimals,
  }) {
    final writer = format.encoder(decimals: decimals);
    writeTo(writer.content);
    return writer.toText();
  }
}
