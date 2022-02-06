// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/geobase.dart';

/// An interface defining the capability to write feature objects.
abstract class FeatureWritable {
  /// Default `const` constructor to allow extending this abstract class.
  const FeatureWritable();

  /// Writes this feature object to [writer].
  void writeTo(FeatureWriter writer);

  /// A string representation of this object, with an optional [format] applied.
  ///
  /// When [format] is not given, then [geoJsonFormat] is used.
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  String toStringAs({FeatureFormat? format, int? decimals}) {
    final f = format ?? geoJsonFormat();
    final writer = f.featuresToText(decimals: decimals);
    writeTo(writer);
    return writer.toString();
  }
}
