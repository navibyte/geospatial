// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

/// A scalable object at the [zoom] level.
@immutable
class Scalable {
  final num _zoom;

  /// Create a scalable object at the [zoom] level.
  const Scalable({required num zoom}) : _zoom = zoom;

  /// The level of detail (or "zoom") for this scalable object.
  num get zoom => _zoom;
}
