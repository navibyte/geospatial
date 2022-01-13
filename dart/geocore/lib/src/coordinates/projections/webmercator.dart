// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import '/src/base/spatial.dart';
import '/src/coordinates/cartesian.dart';
import '/src/coordinates/geographic.dart';

// More information about WGS 84 and Web Mercator
// https://epsg.io/3857
// https://en.wikipedia.org/wiki/Web_Mercator_projection
// https://alastaira.wordpress.com/2011/01/23/the-google-maps-bing-maps-spherical-mercator-projection/
// https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system
// https://athene-forschung.unibw.de/doc/132233/132233.pdf (Some Principles of Web Mercator Maps and their Computation)

/// A projection adapter between WGS84 geographic and Web Mercator points.
///
/// Use `forward` of the adapter to return a projection for:
/// * source: `lon` and `lat` coordinates ("EPSG:4326" / WGS84)
/// * target: `x` and `y` coordinates ("EPSG:3857" / Web Mercator)
///
/// Use `inverse` of the adapter to return a projection for:
/// * source: `x` and `y` coordinates ("EPSG:3857" / Web Mercator)
/// * target: `lon` and `lat` coordinates ("EPSG:4326" / WGS84)
///
/// Other coordinates, if available in the source and if expected for target
/// coordinates, are just copied (`elev` <=> `z` and `m` <=> `m`) without any
/// changes.
const ProjectionAdapter<GeoPoint, CartesianPoint> wgs84ToWebMercator =
    _Wgs84ToWebMercatorAdapter();

class _Wgs84ToWebMercatorAdapter
    with ProjectionAdapter<GeoPoint, CartesianPoint> {
  const _Wgs84ToWebMercatorAdapter();

  @override
  String get fromCrs => 'EPSG:4326';

  @override
  String get toCrs => 'EPSG:3857';

  @override
  Projection<R> forward<R extends CartesianPoint>(
    PointFactory<R> factory,
  ) =>
      _Wgs84ToWebMercatorProjection(factory);

  @override
  Projection<R> inverse<R extends GeoPoint>(
    PointFactory<R> factory,
  ) =>
      _WebMercatorToWgs84Projection(factory);
}

class _Wgs84ToWebMercatorProjection<R extends CartesianPoint>
    with Projection<R> {
  const _Wgs84ToWebMercatorProjection(this.factory);

  final PointFactory<R> factory;

  @override
  R projectPoint(Point source, {PointFactory<R>? to}) {
    // source coordinates
    final lon = source.x; // longitude is at x
    final lat = source.y; // latitude is at y

    // project (lon, lat) to (x, y)
    final x = lon * 20037508.34 / 180.0;
    final y0 =
        math.log(math.tan((90.0 + lat) * math.pi / 360.0)) / (math.pi / 180.0);
    final y = y0 * 20037508.34 / 180;

    // return a projected point with optional z and m coordinates unchanged
    return (to ?? factory).newWith(
      x: x,
      y: y,
      z: source.z,
      m: source.m,
    );
  }
}

class _WebMercatorToWgs84Projection<R extends GeoPoint> with Projection<R> {
  const _WebMercatorToWgs84Projection(this.factory);

  final PointFactory<R> factory;

  @override
  R projectPoint(Point source, {PointFactory<R>? to}) {
    // source coordinates
    final x = source.x;
    final y = source.y;

    // unproject (x, y) to (lon, lat)
    final lon = (x / 20037508.34) * 180.0;
    final lat0 = (y / 20037508.34) * 180.0;
    final lat = 180.0 /
        math.pi *
        (2 * math.atan(math.exp(lat0 * math.pi / 180.0)) - math.pi / 2);

    // return an unprojected point with optional z and m coords unchanged
    return (to ?? factory).newWith(
      x: lon,
      y: lat,
      z: source.z,
      m: source.m,
    );
  }
}
