// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/projection.dart';

import 'web_mercator_projection.dart';

/// Projections for the WGS 84 geographic coordinate system.
class WGS84 {
  /// A projection adapter between WGS84 geographic and Web Mercator positions.
  ///
  /// Use `forward` of the adapter to return a projection for:
  /// * source: `lon` and `lat` coordinates ("EPSG:4326", WGS 84)
  /// * target: `x` and `y` coordinates ("EPSG:3857", WGS 84 / Web Mercator)
  ///
  /// Use `inverse` of the adapter to return a projection for:
  /// * source: `x` and `y` coordinates ("EPSG:3857", WGS 84 / Web Mercator)
  /// * target: `lon` and `lat` coordinates ("EPSG:4326", WGS 84)
  ///
  /// Other coordinates, if available in the source and if expected for target
  /// coordinates, are just copied (`elev` <=> `z` and `m` <=> `m`) without any
  /// changes.
  static const ProjectionAdapter webMercator = Wgs84ToWebMercatorAdapter();

  // NOTE : UTM projections for WGS84, etc.
}
