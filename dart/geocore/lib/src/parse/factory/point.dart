// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/base/spatial.dart';
import '/src/coordinates/cartesian.dart';
import '/src/coordinates/geographic.dart';

/// A constant factory for geographic [GeoPoint] objects without M coordinate.
///
/// Result type candidates for objects created by the factory: [GeoPoint2],
/// [GeoPoint3].
const PointFactory<GeoPoint> geographicPoints = _CreateGeoPoint();

/// Returns a factory for geographic [GeoPoint] objects allowing M coordinate.
///
/// Result type candidates for objects created by a factory: [GeoPoint2],
/// [GeoPoint2m], [GeoPoint3], [GeoPoint3m].
PointFactory<GeoPoint> geographicPointsWithM({required bool expectM}) =>
    _CreateGeoPointAllowingM(expectM: expectM);

/// A constant factory for [CartesianPoint] objects without M coordinate.
///
/// Result type candidates for objects created by the factory: [Point2],
/// [Point3].
const PointFactory<CartesianPoint> cartesianPoints = _CreateCartesianPoint();

/// Returns a factory for [CartesianPoint] objects allowing M coordinate.
///
/// Result type candidates for objects created by a factory: [Point2],
/// [Point2m], [Point3], [Point3m].
PointFactory<CartesianPoint> cartesianPointsWithM({required bool expectM}) =>
    _CreateCartesianPointAllowingM(expectM: expectM);

/// Returns a factory for cartesian and geographic [Point] objects without M.
///
/// Result type candidates for objects created by a factory: [Point2], [Point3],
/// [GeoPoint2], [GeoPoint3].
PointFactory anyPoints({bool expectGeographic = true}) =>
    _CreateAnyPoint(expectGeographic: expectGeographic);

/// Returns a factory for cartesian and geographic [Point] objects allowing M.
///
/// Result type candidates for objects created by a factory: [Point2],
/// [Point2m], [Point3], [Point3m], [GeoPoint2], [GeoPoint2m], [GeoPoint3],
/// [GeoPoint3m].
PointFactory<Point> anyPointsWithM({
  bool expectGeographic = true,
  required bool expectM,
}) =>
    _CreateAnyPointAllowingM(
      expectGeographic: expectGeographic,
      expectM: expectM,
    );

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

class _CreateGeoPoint implements PointFactory<GeoPoint> {
  const _CreateGeoPoint();

  @override
  bool get hasM => false;

  @override
  GeoPoint newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(2, coords, offset: offset, length: length);
    final len = length ?? coords.length;
    if (len >= 3) {
      return GeoPoint3.from(coords, offset: offset);
    } else if (len == 2) {
      return GeoPoint2.from(coords, offset: offset);
    }
    throw _notValidPoint(coords, offset: offset, length: length);
  }

  @override
  GeoPoint newWith({num x = 0.0, num y = 0.0, num? z, num? m}) => z != null
      ? GeoPoint3.lonLatElev(x.toDouble(), y.toDouble(), z.toDouble())
      : GeoPoint2.lonLat(x.toDouble(), y.toDouble());
}

class _CreateGeoPointAllowingM extends _CreateGeoPoint {
  const _CreateGeoPointAllowingM({required bool expectM}) : hasM = expectM;

  @override
  final bool hasM;

  @override
  GeoPoint newFrom(Iterable<num> coords, {int? offset, int? length}) {
    if (!hasM) {
      return super.newFrom(coords, offset: offset, length: length);
    } else {
      CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
      final len = length ?? coords.length;
      if (len >= 4) {
        return GeoPoint3m.from(coords, offset: offset);
      } else if (len == 3) {
        return GeoPoint2m.from(coords, offset: offset);
      }
      throw _notValidPoint(coords, offset: offset, length: length);
    }
  }

  @override
  GeoPoint newWith({num x = 0.0, num y = 0.0, num? z, num? m}) {
    if (!hasM) {
      return super.newWith(x: x, y: y, z: z, m: m);
    } else {
      return z != null
          ? GeoPoint3m.lonLatElevM(
              x.toDouble(),
              y.toDouble(),
              z.toDouble(),
              m?.toDouble() ?? 0.0,
            )
          : GeoPoint2m.lonLatM(
              x.toDouble(),
              y.toDouble(),
              m?.toDouble() ?? 0.0,
            );
    }
  }
}

class _CreateCartesianPoint implements PointFactory<CartesianPoint> {
  const _CreateCartesianPoint();

  @override
  bool get hasM => false;

  @override
  CartesianPoint newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(2, coords, offset: offset, length: length);
    final len = length ?? coords.length;
    if (len >= 3) {
      return Point3.from(coords, offset: offset);
    } else if (len == 2) {
      return Point2.from(coords, offset: offset);
    }
    throw _notValidPoint(coords, offset: offset, length: length);
  }

  @override
  CartesianPoint newWith({num x = 0.0, num y = 0.0, num? z, num? m}) =>
      z != null
          ? Point3.xyz(x.toDouble(), y.toDouble(), z.toDouble())
          : Point2.xy(x.toDouble(), y.toDouble());
}

class _CreateCartesianPointAllowingM extends _CreateCartesianPoint {
  const _CreateCartesianPointAllowingM({required bool expectM})
      : hasM = expectM;

  @override
  final bool hasM;

  @override
  CartesianPoint newFrom(Iterable<num> coords, {int? offset, int? length}) {
    if (!hasM) {
      return super.newFrom(coords, offset: offset, length: length);
    } else {
      CoordinateFactory.checkCoords(3, coords, offset: offset, length: length);
      final len = length ?? coords.length;
      if (len >= 4) {
        return Point3m.from(coords, offset: offset);
      } else if (len == 3) {
        return Point2m.from(coords, offset: offset);
      }
      throw _notValidPoint(coords, offset: offset, length: length);
    }
  }

  @override
  CartesianPoint newWith({num x = 0.0, num y = 0.0, num? z, num? m}) {
    if (!hasM) {
      return super.newWith(x: x, y: y, z: z, m: m);
    } else {
      return z != null
          ? Point3m.xyzm(
              x.toDouble(),
              y.toDouble(),
              z.toDouble(),
              m?.toDouble() ?? 0.0,
            )
          : Point2m.xym(x.toDouble(), y.toDouble(), m?.toDouble() ?? 0.0);
    }
  }
}

class _CreateAnyPoint implements PointFactory {
  const _CreateAnyPoint({
    this.expectGeographic = true,
  });

  final bool expectGeographic;

  @override
  bool get hasM => false;

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    if (expectGeographic) {
      return const _CreateGeoPoint()
          .newFrom(coords, offset: offset, length: length);
    } else {
      return const _CreateCartesianPoint()
          .newFrom(coords, offset: offset, length: length);
    }
  }

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) {
    if (expectGeographic) {
      return const _CreateGeoPoint().newWith(x: x, y: y, z: z, m: m);
    } else {
      return const _CreateCartesianPoint().newWith(x: x, y: y, z: z, m: m);
    }
  }
}

class _CreateAnyPointAllowingM implements PointFactory {
  const _CreateAnyPointAllowingM({
    this.expectGeographic = true,
    required bool expectM,
  }) : hasM = expectM;

  final bool expectGeographic;

  @override
  final bool hasM;

  @override
  Point newFrom(Iterable<num> coords, {int? offset, int? length}) {
    if (expectGeographic) {
      return _CreateGeoPointAllowingM(expectM: hasM)
          .newFrom(coords, offset: offset, length: length);
    } else {
      return _CreateCartesianPointAllowingM(expectM: hasM)
          .newFrom(coords, offset: offset, length: length);
    }
  }

  @override
  Point newWith({num x = 0.0, num y = 0.0, num? z, num? m}) {
    if (expectGeographic) {
      return _CreateGeoPointAllowingM(expectM: hasM)
          .newWith(x: x, y: y, z: z, m: m);
    } else {
      return _CreateCartesianPointAllowingM(expectM: hasM)
          .newWith(x: x, y: y, z: z, m: m);
    }
  }
}

FormatException _notValidPoint(
  Iterable<num> coords, {
  int? offset,
  int? length,
}) =>
    FormatException('Not a valid point with ${coords.length} coordinates.');
