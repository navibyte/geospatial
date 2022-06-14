// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import 'package:meta/meta.dart';

/// A scalable object at the [zoom] level (a positive number).
@immutable
class Scalable {
  final num _zoom;

  /// Create a scalable object at the [zoom] level (a positive number).
  const Scalable({required num zoom})
      : _zoom = zoom,
        assert(zoom >= 0, 'Zoom must be >= 0');

  /// The level of detail (or "zoom") for this scalable object.
  num get zoom => _zoom;

  /// Zooms in by one.
  Scalable zoomIn() => Scalable(zoom: zoom + 1);

  /// Zooms out by one.
  /// 
  /// The minimum value for [zoom] of the returned scalable object is 0.
  Scalable zoomOut() => Scalable(zoom: math.max(zoom - 1, 0));

  /// Zooms to the [zoom] level (a positive number).
  Scalable zoomTo(covariant num zoom) => Scalable(zoom: zoom);
}
