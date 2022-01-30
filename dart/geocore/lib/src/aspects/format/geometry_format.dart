// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/aspects/encode.dart';

/// An interface specifying methods to format geometry objects.
abstract class GeometryFormat {
  /// Returns a writer formatting string representations of bounds.
  ///
  /// When an optional [buffer] is given, then representations are written into
  /// it (without clearing any content it might already contain).
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// After writing some objects with coordinate data into a writer, the string
  /// representation can be accessed using `toString()` of it (or via [buffer]
  /// when such is given).
  BoundsWriter boundsToText({StringSink? buffer, int? decimals});

  /// Returns a writer formatting string representations of coordinate data.
  ///
  /// When an optional [buffer] is given, then representations are written into
  /// it (without clearing any content it might already contain).
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// After writing some objects with coordinate data into a writer, the string
  /// representation can be accessed using `toString()` of it (or via [buffer]
  /// when such is given).
  CoordinateWriter coordinatesToText({StringSink? buffer, int? decimals});

  /// Returns a writer formatting string representations of geometry objects.
  ///
  /// When an optional [buffer] is given, then representations are written into
  /// it (without clearing any content it might already contain).
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// After writing some objects with coordinate data into a writer, the string
  /// representation can be accessed using `toString()` of it (or via [buffer]
  /// when such is given).
  GeometryWriter geometryToText({StringSink? buffer, int? decimals});
}
