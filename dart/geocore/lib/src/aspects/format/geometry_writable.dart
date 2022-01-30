// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/encode.dart';

import 'features_format.dart';
import 'geometry_format.dart';

/// An interface defining the capability to write geometry objects.
abstract class GeometryWritable {
  /// Writes this object to [writer].
  void writeGeometry(GeometryWriter writer);

  /// A string representation of this object, with [format] applied.
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  String toStringAs({GeometryFormat format = defaultFormat, int? decimals});

  /// A string representation of this object, with the [defaultFormat] applied.
  @override
  String toString();
}

/// A mixin with the base capability to write write geometry objects.
mixin GeometryWritableMixin implements GeometryWritable {
  @override
  String toStringAs({GeometryFormat format = defaultFormat, int? decimals}) {
    final writer = format.geometryToText(decimals: decimals);
    writeGeometry(writer);
    return writer.toString();
  }

  @override
  String toString() {
    final writer = defaultFormat.geometryToText();
    writeGeometry(writer);
    return writer.toString();
  }

  // note : toString() implementation may need reimplementation on sub classes
  //        if some other class or mixin hides this toString impl
  //        (it might be efficient to provide a specific toString on sub class)
}
