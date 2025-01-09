// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_redundant_argument_values

import '/src/common/reference/coord_ref_sys.dart';
import '/src/coordinates/projection/projection_adapter.dart';
import '/src/geodesy/ellipsoidal/datum.dart';
import '/src/projections/ellipsoidal/ellipsoidal_projection_adapter.dart';

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
}
