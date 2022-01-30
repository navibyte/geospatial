// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'coordinate_writer.dart';

/// An interface defining the capability to write coordinate data.
abstract class CoordinateWritable {
  /// Writes this object to [writer].
  void writeCoordinates(CoordinateWriter writer);

  /// A string representation of this object, with the default format applied.
  @override
  String toString();
}
