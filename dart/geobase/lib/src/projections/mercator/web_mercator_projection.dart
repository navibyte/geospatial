// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/base.dart';
import '/src/coordinates/geographic.dart';
import '/src/coordinates/projected.dart';
import '/src/coordinates/projection.dart';
import '/src/utils/web_mercator_converter.dart';

// More information about WGS 84 and Web Mercator
// https://epsg.io/3857
// https://en.wikipedia.org/wiki/Web_Mercator_projection
// https://alastaira.wordpress.com/2011/01/23/the-google-maps-bing-maps-spherical-mercator-projection/
// https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system
// https://athene-forschung.unibw.de/doc/132233/132233.pdf (Some Principles of Web Mercator Maps and their Computation)

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
const ProjectionAdapter wgs84ToWebMercator = _Wgs84ToWebMercatorAdapter();

// A local helper class for conversions.
const _converter = WebMercatorConverter.epsg3857();

class _Wgs84ToWebMercatorAdapter with ProjectionAdapter {
  const _Wgs84ToWebMercatorAdapter();

  @override
  String get fromCrs => 'EPSG:4326';

  @override
  String get toCrs => 'EPSG:3857';

  @override
  Projection<Projected> forward() =>
      const _Wgs84ToWebMercatorProjection(Projected.create);

  @override
  Projection<R> forwardTo<R extends Position>(
    CreatePosition<R> factory,
  ) =>
      _Wgs84ToWebMercatorProjection(factory);

  @override
  Projection<Geographic> inverse() =>
      const _WebMercatorToWgs84Projection(Geographic.create);

  @override
  Projection<R> inverseTo<R extends Position>(
    CreatePosition<R> factory,
  ) =>
      _WebMercatorToWgs84Projection(factory);
}

class _Wgs84ToWebMercatorProjection<R extends Position> with Projection<R> {
  const _Wgs84ToWebMercatorProjection(this.factory);

  final CreatePosition<R> factory;

  @override
  R project(Position source, {CreatePosition<R>? to}) {
    // source coordinates
    final lon = source.x; // longitude at x
    final lat = source.y; // latitude at y

    // return a projected position
    return (to ?? factory).call(
      // project (lon, lat) to (x, y)
      x: _converter.toProjectedX(lon),
      y: _converter.toProjectedY(lat),
      // optional z and m coordinates unchanged
      z: source.optZ,
      m: source.optM,
    );
  }
}

class _WebMercatorToWgs84Projection<R extends Position> with Projection<R> {
  const _WebMercatorToWgs84Projection(this.factory);

  final CreatePosition<R> factory;

  @override
  R project(Position source, {CreatePosition<R>? to}) {
    // return an unprojected position
    return (to ?? factory).call(
      // unproject (x, y) to (lon, lat)
      x: _converter.fromProjectedX(source.x),
      y: _converter.fromProjectedY(source.y),
      // optional z and m coords unchanged
      z: source.optZ,
      m: source.optM,
    );
  }
}
