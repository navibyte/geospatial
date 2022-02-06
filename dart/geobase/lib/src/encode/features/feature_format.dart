// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/encode/geometry.dart';

import 'feature_writer.dart';

/// An interface for geospatial features (+ geometries and coordinates) format.
mixin FeatureFormat implements GeometryFormat {
  /// Returns a writer formatting string representations of feature objects.
  ///
  /// When an optional [buffer] is given, then representations are written into
  /// it (without clearing any content it might already contain).
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// After writing some objects with coordinate data into a writer, the string
  /// representation can be accessed using `toString()` of it (or via [buffer]
  /// when such is given).
  FeatureWriter featuresToText({StringSink? buffer, int? decimals});
}
