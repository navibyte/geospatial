// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/crs/coord_ref_sys.dart';
import '/src/coordinates/projection/projection.dart';
import '/src/coordinates/projection/projection_adapter.dart';
import '/src/utils/format_validation.dart';
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
  CoordRefSys get fromCoordRefSys => CoordRefSys.CRS84;

  @override
  CoordRefSys get toCoordRefSys => CoordRefSys.EPSG_3857;

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

  @override
  List<double> projectCoords(
    Iterable<double> source, {
    List<double>? target,
    required Coords type,
  }) {
    final dim = type.coordinateDimension;
    final result = target ?? List<double>.filled(source.length, 0.0);

    var offset = 0;
    final iter = source.iterator;
    while (iter.moveNext()) {
      // project (lon, lat) to (x, y)
      result[offset] = _converter.toProjectedX(iter.current);
      result[offset + 1] = iter.moveNext()
          ? _converter.toProjectedY(iter.current)
          : throw invalidCoordinates;
      // optional z and m coordinates unchanged
      if (dim >= 3) {
        result[offset + 2] =
            iter.moveNext() ? iter.current : throw invalidCoordinates;
      }
      if (dim >= 4) {
        result[offset + 3] =
            iter.moveNext() ? iter.current : throw invalidCoordinates;
      }
      offset += dim;
    }

    return result;
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

  @override
  List<double> projectCoords(
    Iterable<double> source, {
    List<double>? target,
    required Coords type,
  }) {
    final dim = type.coordinateDimension;
    final result = target ?? List<double>.filled(source.length, 0.0);

    var offset = 0;
    final iter = source.iterator;
    while (iter.moveNext()) {
      // unproject (x, y) to (lon, lat)
      result[offset] = _converter.fromProjectedX(iter.current);
      result[offset + 1] = iter.moveNext()
          ? _converter.fromProjectedY(iter.current)
          : throw invalidCoordinates;
      // optional z and m coords unchanged
      if (dim >= 3) {
        result[offset + 2] =
            iter.moveNext() ? iter.current : throw invalidCoordinates;
      }
      if (dim >= 4) {
        result[offset + 3] =
            iter.moveNext() ? iter.current : throw invalidCoordinates;
      }
      offset += dim;
    }

    return result;
  }
}
