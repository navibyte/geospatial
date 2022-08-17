// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/coordinates/base.dart';
import '/src/coordinates/projection.dart';
import '/src/utils/web_mercator_converter.dart';

// More information about WGS 84 and Web Mercator
// https://epsg.io/3857
// https://en.wikipedia.org/wiki/Web_Mercator_projection
// https://alastaira.wordpress.com/2011/01/23/the-google-maps-bing-maps-spherical-mercator-projection/
// https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system
// https://athene-forschung.unibw.de/doc/132233/132233.pdf (Some Principles of Web Mercator Maps and their Computation)

// A local helper class for conversions.
const _converter = WebMercatorConverter.epsg3857();

/// A projection adapter between WGS84 geographic and Web Mercator positions.
@internal
class Wgs84ToWebMercatorAdapter with ProjectionAdapter {
  /// A projection adapter between WGS84 geographic and Web Mercator positions.
  const Wgs84ToWebMercatorAdapter();

  @override
  String get fromCrs => 'EPSG:4326';

  @override
  String get toCrs => 'EPSG:3857';

  @override
  Projection get forward => const _Wgs84ToWebMercatorProjection();

  @override
  Projection get inverse => const _WebMercatorToWgs84Projection();
}

class _Wgs84ToWebMercatorProjection with Projection {
  const _Wgs84ToWebMercatorProjection();

  @override
  R project<R extends Position>(
    Position source, {
    required CreatePosition<R> to,
  }) {
    // source coordinates
    final lon = source.x; // longitude at x
    final lat = source.y; // latitude at y

    // return a projected position
    return to.call(
      // project (lon, lat) to (x, y)
      x: _converter.toProjectedX(lon),
      y: _converter.toProjectedY(lat),
      // optional z and m coordinates unchanged
      z: source.optZ,
      m: source.optM,
    );
  }
}

class _WebMercatorToWgs84Projection with Projection {
  const _WebMercatorToWgs84Projection();

  @override
  R project<R extends Position>(
    Position source, {
    required CreatePosition<R> to,
  }) {
    // return an unprojected position
    return to.call(
      // unproject (x, y) to (lon, lat)
      x: _converter.fromProjectedX(source.x),
      y: _converter.fromProjectedY(source.y),
      // optional z and m coords unchanged
      z: source.optZ,
      m: source.optM,
    );
  }
}
