// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/encode.dart';

import 'feature_format.dart';

/// An interface defining the capability to write feature objects.
abstract class FeatureWritable {
  /// Writes this object to [writer].
  void writeFeatures(FeatureWriter writer);

  /// A string representation of this object, with an optional [format] applied.
  /// 
  /// When [format] is not given, then [geoJsonFormat] is used.
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  String toStringAs({FeatureFormat? format, int? decimals});

  /// A string representation of this object, with the [geoJsonFormat] applied.
  @override
  String toString();
}

/// A mixin with the base capability to write write feature objects.
mixin FeatureWritableMixin implements FeatureWritable {
  @override
  String toStringAs({FeatureFormat? format, int? decimals}) {
    final f = format ?? geoJsonFormat();
    final writer = f.featuresToText(decimals: decimals);
    writeFeatures(writer);
    return writer.toString();
  }

  @override
  String toString() {
    final f = geoJsonFormat();
    final writer = f.featuresToText();
    writeFeatures(writer);
    return writer.toString();
  }

  // note : toString() implementation may need reimplementation on sub classes
  //        if some other class or mixin hides this toString impl
  //        (it might be efficient to provide a specific toString on sub class)
}
