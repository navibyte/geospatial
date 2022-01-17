// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'coordinate_format.dart';

/// An interface for objects formattable as coordinates or sets of coordinates.
abstract class CoordinateFormattable {
  /// Writes coordinates to [buffer] as defined by [format].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  void writeString(
    StringSink buffer, {
    CoordinateFormat format = defaultFormat,
    int? decimals,
  });

  /// A string representation of coordinates as defined by [format].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  String toStringAs({
    CoordinateFormat format = defaultFormat,
    int? decimals,
  });

  /// A string representation of coordinates as defined by [wktFormat].
  ///
  /// Use [decimals] to set a number of decimals to nums with decimals.
  String toStringWkt({int? decimals});

  /// A string representation of coordinates as defined by [defaultFormat].
  @override
  String toString();
}

/// A partial implementation of [CoordinateFormattable] as a mixin.
/// 
/// Provides default implementation to all other methods but [writeString] that
/// must be always implemented by actual classes representing coordinate data.
mixin CoordinateFormattableMixin implements CoordinateFormattable {
  @override
  String toStringAs({
    CoordinateFormat format = defaultFormat,
    int? decimals,
  }) {
    final buf = StringBuffer();
    writeString(buf, format: format, decimals: decimals);
    return buf.toString();
  }

  @override
  String toStringWkt({int? decimals}) {
    final buf = StringBuffer();
    writeString(buf, format: wktFormat, decimals: decimals);
    return buf.toString();
  }

  @override
  String toString() {
    final buf = StringBuffer();
    writeString(buf);
    return buf.toString();
  }

  // note : toString() implementation may need reimplementation on sub classes
  //        if some other class or mixin hides this toString impl
  //        (it might be efficient to provide a specific toString on sub class)
}
