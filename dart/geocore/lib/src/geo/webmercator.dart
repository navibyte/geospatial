// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math' as math;

import '../base.dart';

import 'geopoint.dart';

// More information about WGS 84 and Web Mercator
// https://epsg.io/3857
// https://en.wikipedia.org/wiki/Web_Mercator_projection
// https://alastaira.wordpress.com/2011/01/23/the-google-maps-bing-maps-spherical-mercator-projection/
// https://docs.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system
// https://athene-forschung.unibw.de/doc/132233/132233.pdf (Some Principles of Web Mercator Maps and their Computation)

/// Returns a function that projects geographic points to web mercator points.
///
/// By default, target points of [R] are created using [factory].
///
/// The returned conversion function expects source coordinates to be in the
/// `CRS84` (that is 'WGS 84 longitude-latitude' or EPSG:4326) coordinate
/// reference system. Source `lon` and `lat` coordinates are converted to target
/// `x` and `y` coordinates (meters) of the Web Mercator (EPSG:3857) projection.
///
/// Other coordinates, if available in the source and if expected to target
/// coordinates, are then copied (`elev` => `z` and `m` => `m`) without any
/// changes.
ProjectPoint<GeoPoint, R> wgs84ToWebMercator<R extends CartesianPoint>(
  PointFactory<R> factory,
) =>
    (GeoPoint source, {PointFactory<R>? to}) {
      // source coordinates
      final lon = source.lon;
      final lat = source.lat;

      // project (lon, lat) to (x, y)
      final x = lon * 20037508.34 / 180.0;
      final y0 = math.log(math.tan((90.0 + lat) * math.pi / 360.0)) /
          (math.pi / 180.0);
      final y = y0 * 20037508.34 / 180;

      // return a projected point with optional z and m coordinates unchanged
      return (to ?? factory).newWith(
        x: x,
        y: y,
        z: source.z,
        m: source.m,
      );
    };

/// Returns a function that unprojects web mercator points to geographic points.
///
/// By default, target points of [R] are created using [factory].
///
/// The returned conversion function expects source coordinates to be in the
/// Web Mercator (EPSG:3857) projection. Source `x` and `y` coordinates (meters)
/// are converted to target `lon` and `lat` coordinates of the `CRS84` (that is
/// 'WGS 84 longitude-latitude' or EPSG:4326) coordinate reference system.
///
/// Other coordinates, if available in the source and if expected to target
/// coordinates, are then copied  (`z` => `elev` and `m` => `m`) without any
/// changes.
ProjectPoint<CartesianPoint, R> webMercatorToWgs84<R extends GeoPoint>(
  PointFactory<R> factory,
) =>
    (CartesianPoint source, {PointFactory<R>? to}) {
      // source coordinates
      final x = source.x;
      final y = source.y;

      // unproject (x, y) to (lon, lat)
      final lon = (x / 20037508.34) * 180.0;
      final lat0 = (y / 20037508.34) * 180.0;
      final lat = 180.0 /
          math.pi *
          (2 * math.atan(math.exp(lat0 * math.pi / 180.0)) - math.pi / 2);

      // return an unprojected point with optional z and m coordinates unchanged
      return (to ?? factory).newWith(
        x: lon,
        y: lat,
        z: source.z,
        m: source.m,
      );
    };
