// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_redundant_argument_values

import '/src/common/reference/coord_ref_sys.dart';
import '/src/coordinates/projection/projection_adapter.dart';
import '/src/geodesy/ellipsoidal/datum.dart';
import '/src/geodesy/ellipsoidal/utm.dart';
import '/src/projections/ellipsoidal/ellipsoidal_projection_adapter.dart';
import '/src/projections/ellipsoidal/utm_projection_adapter.dart';

import 'web_mercator_projection.dart';

/// Projections for the WGS 84 geographic coordinate system.
class WGS84 {
  const WGS84._();

  /// A projection adapter between WGS84 geographic and Web Mercator positions
  /// (using "spherical development" of WGS84 ellipsoidal coordinates).
  ///
  /// Use `forward` of the adapter to return a projection for:
  /// * source: `lon` and `lat` geographic coordinates (WGS 84)
  /// * target: `x` and `y` coordinates ("EPSG:3857", WGS 84 / Web Mercator)
  ///
  /// Use `inverse` of the adapter to return a projection for:
  /// * source: `x` and `y` coordinates ("EPSG:3857", WGS 84 / Web Mercator)
  /// * target: `lon` and `lat` geographic coordinates (WGS 84)
  ///
  /// Other coordinates, if available in the source and if expected for target
  /// coordinates, are just copied (`elev` <=> `z` and `m` <=> `m`) without any
  /// changes.
  static const ProjectionAdapter webMercator = Wgs84ToWebMercatorAdapter();

  /// A projection adapter between WGS84 geographic and geocentric cartesian
  /// positions (using the WGS84 ellipsoidal datum).
  ///
  /// Use `forward` of the adapter to return a projection for:
  /// * source: `lon`, `lat` and `elev` (h) geographic coordinates (WGS 84)
  /// * target: `x`, `y` and `z` coordinates ("EPSG:4978", WGS 84 / geocentric)
  ///
  /// Use `inverse` of the adapter to return a projection for:
  /// * source: `x`, `y` and `z` coordinates ("EPSG:4978", WGS 84 / geocentric)
  /// * target: `lon`, `lat` and `elev` (h) geographic coordinates (WGS 84)
  ///
  /// Other coordinates, if available in the source and if expected for target
  /// coordinates, are just copied (`m` <=> `m`) without any changes.
  ///
  /// {@template geobase.projections.wgs84.datumAccuracy}
  ///
  /// The accuracy on conversions using other than the [Datum.WGS84] datum is
  /// not guaranteed. The accuracy depends on the transformation parameter of
  /// the Helmert 7-parameter transformation used in the conversion.
  ///
  /// {@endtemplate}
  static final ProjectionAdapter geocentric =
      EllipsoidalProjectionAdapter.geographicToGeocentric(
    // source is geographic coordinates in WGS 84
    sourceCrs: CoordRefSys.CRS84,
    sourceDatum: Datum.WGS84,

    // target is geocentric coordinates in WGS 84
    targetCrs: CoordRefSys.EPSG_4978,
    targetDatum: Datum.WGS84,
  );

  /// A projection adapter between WGS84 geographic and geographic positions
  /// on the target datum.
  ///
  /// Use `forward` of the adapter to return a projection for:
  /// * source: `lon` and `lat` geographic coordinates (WGS 84)
  /// * target: `lon` and `lat` geographic coordinates on the target datum
  ///
  /// Use `inverse` of the adapter to return a projection for:
  /// * source: `lon` and `lat` geographic coordinates on the target datum
  /// * target: `lon` and `lat` geographic coordinates (WGS 84)
  ///
  /// {@macro geobase.projections.wgs84.datumAccuracy}
  static ProjectionAdapter geographicToDatum(
    CoordRefSys targetCrs,
    Datum targetDatum,
  ) {
    return EllipsoidalProjectionAdapter.geographicToGeographic(
      // source is geographic coordinates in WGS 84
      sourceCrs: CoordRefSys.CRS84,
      sourceDatum: Datum.WGS84,

      // target is geographic coordinates on the target datum
      targetCrs: targetCrs,
      targetDatum: targetDatum,
    );
  }

  /// A projection adapter between WGS84 geographic and UTM projected positions.
  ///
  /// Use `forward` of the adapter to return a projection for:
  /// * source: `lon` and `lat` geographic coordinates (WGS 84)
  /// * target: `easting` and `northing` UTM projected coordinates in the given
  ///   zone (UTM/WGS 84 or UTM in the target datum if specified)
  ///
  /// Use `inverse` of the adapter to return a projection for:
  /// * source: `easting` and `northing` UTM projected coordinates in the given
  ///   zone (UTM/WGS 84 or UTM in the target datum if specified)
  /// * target: `lon` and `lat` geographic coordinates (WGS 84)
  ///
  /// By default both source and target are based on the WGS 84 datum. If
  /// different datum is needed for the target, then specify it with both
  /// [targetCrs] and [targetDatum] (both must be non-null then).
  ///
  /// {@template geobase.projections.wgs84.utm}
  ///
  /// Projected UTM positions are based on the WGS 84 ellipsoidal datum.
  /// Positions locate inside on of the 60 UTM zones (1-60) and in one of the
  /// two hemispheres (north or south). The zone is determined by the longitude
  /// and the hemisphere by the latitude of the position.
  ///
  /// It's possible to specify the zone and the hemisphere so that the source
  /// position is not actually inside the zone. In such case projected
  /// coordinates may contain strange values.
  ///
  /// You can also use the [Utm] class from the `geodesy` sub package to convert
  /// between geographic and UTM projected coordinates. This also allows
  /// converting from a geographic position to a UTM position with the zone and
  /// the hemisphere determined by that position without setting them. It also
  /// supports accessing metadata like the convergence and the scale factor
  /// related to the UTM projection.
  ///
  /// With [UtmZone.fromGeographic] it's possible to calculate the UTM zone and
  /// the hemisphere for a geographic position.
  ///
  /// {@endtemplate}
  ///
  /// {@macro geobase.projections.wgs84.datumAccuracy}
  static ProjectionAdapter utmZone(
    UtmZone zone, {
    CoordRefSys? targetCrs,
    Datum? targetDatum,
  }) {
    final isNonWGS84Target = targetCrs != null && targetDatum != null;
    return UtmProjectionAdapter.geographicToProjected(
      // source is geographic coordinates in WGS 84
      sourceCrs: CoordRefSys.CRS84,
      sourceDatum: Datum.WGS84,

      // target is UTM projected coordinates of the target zone in WGS 84 or the
      // given target datum
      targetCrs: isNonWGS84Target
          ? targetCrs
          : CoordRefSys.utmWgs84(zone.lonZone, zone.hemisphere),
      targetDatum: isNonWGS84Target ? targetDatum : Datum.WGS84,
      targetZone: zone,
    );
  }

  /// A projection adapter between positions projected to different UTM zones
  /// based on the WGS84 datum.
  ///
  /// Use `forward` of the adapter to return a projection for:
  /// * source: `easting` and `northing` UTM projected coordinates in the source
  ///   zone (UTM/WGS 84)
  /// * target: `easting` and `northing` UTM projected coordinates in the target
  ///   zone (UTM/WGS 84)
  ///
  /// Use `inverse` of the adapter to return a projection for:
  /// * source: `easting` and `northing` UTM projected coordinates in the target
  ///   zone (UTM/WGS 84)
  /// * target: `easting` and `northing` UTM projected coordinates in the source
  ///   zone (UTM/WGS 84)
  ///
  /// {@macro geobase.projections.wgs84.utm}
  static ProjectionAdapter utmZoneToZone(
    UtmZone sourceZone,
    UtmZone targetZone,
  ) {
    return UtmProjectionAdapter.projectedToProjected(
      // source is UTM projected coordinates of the source zone in WGS 84
      sourceCrs:
          CoordRefSys.utmWgs84(sourceZone.lonZone, sourceZone.hemisphere),
      sourceDatum: Datum.WGS84,
      sourceZone: sourceZone,

      // target is UTM projected coordinates of the target zone in WGS 84
      targetCrs:
          CoordRefSys.utmWgs84(targetZone.lonZone, targetZone.hemisphere),
      targetDatum: Datum.WGS84,
      targetZone: targetZone,
    );
  }
}
