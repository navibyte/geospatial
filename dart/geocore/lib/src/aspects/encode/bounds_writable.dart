// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'bounds_writer.dart';

/// An interface defining the capability to write  bounds data.
abstract class BoundsWritable {
  /// Writes this object to [writer].
  void writeBounds(BoundsWriter writer);

  /// A string representation of this object, with the default format applied.
  @override
  String toString();
}
