// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'base_writer.dart';

/// A function that is capable of writing bounds to [writer].
typedef WriteBounds = void Function(BoundsWriter writer);

/// An interface to write bounds objects into some content format.
abstract class BoundsWriter extends BaseWriter {
  /// Writes given bounds coordinates.
  void coordBounds({
    required num minX,
    required num minY,
    num? minZ,
    num? minM,
    required num maxX,
    required num maxY,
    num? maxZ,
    num? maxM,
  });
}
