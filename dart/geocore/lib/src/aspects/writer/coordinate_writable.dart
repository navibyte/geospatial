// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'coordinate_format.dart';
import 'coordinate_writer.dart';

/// An interface defining the capability to write objects with coordinate data.
abstract class CoordinateWritable {
  /// Writes this object to [writer].
  void writeTo(CoordinateWriter writer);

  /// A string representation of this object, with [format] applied.
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  String toStringAs({CoordinateFormat format = defaultFormat, int? decimals});

  /// A string representation of this object, with the [defaultFormat] applied.
  @override
  String toString();
}

/// A mixin with the base capability to write objects with coordinate data.
mixin CoordinateWritableMixin implements CoordinateWritable {
  @override
  String toStringAs({CoordinateFormat format = defaultFormat, int? decimals}) {
    final writer = format.text(decimals: decimals);
    writeTo(writer);
    return writer.toString();
  }

  @override
  String toString() {
    final writer = defaultFormat.text();
    writeTo(writer);
    return writer.toString();
  }

  // note : toString() implementation may need reimplementation on sub classes
  //        if some other class or mixin hides this toString impl
  //        (it might be efficient to provide a specific toString on sub class)
}
