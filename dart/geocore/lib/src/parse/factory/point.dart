// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:attributes/values.dart';

import '../../base.dart';
import '../../crs.dart';
import '../../geo.dart';

/// A function to create projected and geographic [Point] objects without M.
///
/// Result type candidates: [Point2], [Point3], [GeoPoint2], [GeoPoint3].
Point createAnyPoint(Iterable coords,
    {CRS expectedCRS = CRS84, bool expectM = false}) {
  if (coords is Iterable<double>) {
    if (expectedCRS.type == CRSType.geographic) {
      return _geoPointFromDouble(coords);
    } else {
      return _pointFromDouble(
        coords,
      );
    }
  } else {
    if (expectedCRS.type == CRSType.geographic) {
      return _geoPointFromDouble(coords.map<double>((e) => valueToDouble(e)));
    } else {
      return _pointFromDouble(
        coords.map<double>((e) => valueToDouble(e)),
      );
    }
  }
}

/// A function to create projected and geographic [Point] objects with M too.
///
/// Result type candidates: [Point2], [Point2m], [Point3], [Point3m],
/// [GeoPoint2], [GeoPoint2m], [GeoPoint3], [GeoPoint3m].
Point createAnyPointWithM(Iterable coords,
    {CRS expectedCRS = CRS84, bool expectM = false}) {
  if (coords is Iterable<double>) {
    if (expectedCRS.type == CRSType.geographic) {
      return _geoPointFromDoubleWithM(
        coords,
        expectM: expectM,
      );
    } else {
      return _pointFromDoubleWithM(
        coords,
        expectM: expectM,
      );
    }
  } else {
    if (expectedCRS.type == CRSType.geographic) {
      return _geoPointFromDoubleWithM(
        coords.map<double>((e) => valueToDouble(e)),
        expectM: expectM,
      );
    } else {
      return _pointFromDoubleWithM(
        coords.map<double>((e) => valueToDouble(e)),
        expectM: expectM,
      );
    }
  }
}

/// A function to create geographic [GeoPoint] objects without M coordinate.
///
/// Result type candidates: [GeoPoint2], [GeoPoint3].
GeoPoint createGeoPoint(Iterable coords,
    {CRS expectedCRS = CRS84, bool expectM = false}) {
  if (coords is Iterable<double>) {
    if (expectedCRS.type == CRSType.geographic) {
      return _geoPointFromDouble(
        coords,
      );
    } else {
      throw _notValidPoint(coords);
    }
  } else {
    if (expectedCRS.type == CRSType.geographic) {
      return _geoPointFromDouble(
        coords.map<double>((e) => valueToDouble(e)),
      );
    } else {
      throw _notValidPoint(coords);
    }
  }
}

/// A function to create geographic [GeoPoint] objects with M too.
///
/// Result type candidates: [GeoPoint2], [GeoPoint2m], [GeoPoint3],
/// [GeoPoint3m].
GeoPoint createGeoPointWithM(Iterable coords,
    {CRS expectedCRS = CRS84, bool expectM = false}) {
  if (coords is Iterable<double>) {
    if (expectedCRS.type == CRSType.geographic) {
      return _geoPointFromDoubleWithM(
        coords,
        expectM: expectM,
      );
    } else {
      throw _notValidPoint(coords);
    }
  } else {
    if (expectedCRS.type == CRSType.geographic) {
      return _geoPointFromDoubleWithM(
        coords.map<double>((e) => valueToDouble(e)),
        expectM: expectM,
      );
    } else {
      throw _notValidPoint(coords);
    }
  }
}

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

/// A point from [coords]: xy or xyz
///
/// Throws FormatException if cannot create point.
Point _pointFromDouble(Iterable<double> coords) {
  if (coords.length >= 3) {
    return Point3.from(coords);
  } else if (coords.length == 2) {
    return Point2.from(coords);
  }
  throw _notValidPoint(coords);
}

/// A point from [coords]: xy or xyz (if [expectM] then could be xyz or xyzm).
///
/// Throws FormatException if cannot create point.
Point _pointFromDoubleWithM(Iterable<double> coords, {bool expectM = false}) {
  if (expectM) {
    if (coords.length >= 4) {
      return Point3m.from(coords);
    } else if (coords.length == 3) {
      return Point2m.from(coords);
    }
  } else {
    if (coords.length >= 3) {
      return Point3.from(coords);
    } else if (coords.length == 2) {
      return Point2.from(coords);
    }
  }
  throw _notValidPoint(coords);
}

/// A GeoPoint from [coords]: 2D or 3D.
///
/// Throws FormatException if cannot create point.
GeoPoint _geoPointFromDouble(Iterable<double> coords) {
  if (coords.length >= 3) {
    return GeoPoint3.from(coords);
  } else if (coords.length == 2) {
    return GeoPoint2.from(coords);
  }
  throw _notValidPoint(coords);
}

/// A GeoPoint from [coords]: 2D, 3D, 2D with m or 3D with m.
///
/// Throws FormatException if cannot create point.
GeoPoint _geoPointFromDoubleWithM(Iterable<double> coords,
    {bool expectM = false}) {
  if (expectM) {
    if (coords.length >= 4) {
      return GeoPoint3m.from(coords);
    } else if (coords.length == 3) {
      return GeoPoint2m.from(coords);
    }
  } else {
    if (coords.length >= 3) {
      return GeoPoint3.from(coords);
    } else if (coords.length == 2) {
      return GeoPoint2.from(coords);
    }
  }
  throw _notValidPoint(coords);
}

FormatException _notValidPoint(Iterable coords) {
  return FormatException(
      'Not a valid point with ${coords.length} coordinates.');
}
