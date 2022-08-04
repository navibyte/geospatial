// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

//import '/src/codes/geom.dart';

import 'package:meta/meta.dart';

import '/src/codes/geom.dart';
import '/src/vector_data/model/bounded.dart';

/// A base interface for geometry classes.
@immutable
abstract class Geometry extends Bounded {
  /// Default `const` constructor to allow extending this abstract class.
  const Geometry();

  /// The geometry type.
  Geom get type;
}
