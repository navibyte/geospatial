// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/coordinates/base.dart';

/// Mapped coordinates with [point] at the [zoom] level.
@immutable
class Mapped<T extends Position2> {
  final num _zoom;
  final T _point;

  /// Create mapped coordinates with [point] at the [zoom] level.
  const Mapped({required num zoom, required T point})
      : _zoom = zoom,
        _point = point;

  /// The level of detail (or "zoom") for mapped coordinates.
  num get zoom => _zoom;

  /// Mapped [point] coordinates at the [zoom] level.
  T get point => _point;
}
