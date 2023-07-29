// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/codes/axis_order.dart';

/// An abstract class for resolving coordinate reference system information.
///
/// A resolver can be accessed using [registry] that is initially instantiated
/// with the basic default implementation. It be customized by registering a
/// custom instance using [register]).
///
/// NOTE: The current version of this resolver class provides only methods
/// [normalizeId], [axisOrder] and [epsg]. In future other methods might be
/// added.
abstract class CoordRefSysResolver {
  const CoordRefSysResolver._();

  /// Normalizes the coordinate reference system identifier to the template
  /// `http://www.opengis.net/def/crs/EPSG/0/4326`.
  ///
  /// Examples:
  /// * `http://www.opengis.net/def/crs/EPSG/0/4326`
  ///    => `http://www.opengis.net/def/crs/EPSG/0/4326`
  /// * `EPSG:4326`
  ///    => `http://www.opengis.net/def/crs/EPSG/0/4326`
  /// * `http://www.opengis.net/def/crs/OGC/1.3/CRS84`
  ///    => `http://www.opengis.net/def/crs/OGC/1.3/CRS84`
  ///
  /// The normalization logic depends on the resolver of [registry].
  String normalizeId(String id);

  /// Returns true if coordinate reference system identified by [id] represents
  /// geographic coordinates.
  ///
  /// Optionally check also that the axis order equals to given axis [order] or
  /// that geographic coordinates are based on the WGS 84 datum.
  bool isGeographic(String id, {bool? wgs84, AxisOrder? order});

  /// Try to resolve an axis order of coordinate values in position and point
  /// representations for this coordinate reference system identified and
  /// specified by [id].
  ///
  /// The `null` return value is interpreted as "the axis order is not known".
  ///
  /// The axis order logic depends on the resolver of [registry].
  AxisOrder? axisOrder(String id);

  /// Returns an EPSG identifier according to the common `EPSG:{code}` template
  /// for [id] if the coordinate reference system is recognized by the
  /// [EPSG register](https://epsg.org/).
  ///
  /// For example for `http://www.opengis.net/def/crs/EPSG/0/4326` (WGS 84
  /// latitude/longitude) this getter returns `EPSG:4326`, but for
  /// `http://www.opengis.net/def/crs/OGC/1.3/CRS84` this returns null as CRS84
  /// (WGS 84 longitude/latitude) do not have an exact corresponding identifier
  /// in the EPSG register.
  String? epsg(String id);

  /// The current instance of [CoordRefSysResolver], initially instantiated with
  /// the basic default implementation.
  ///
  /// The basic implmentation (when [register] is NOT used to register a custom
  /// instance) currently supports identifiers:
  /// * `http://www.opengis.net/def/crs/OGC/1.3/CRS84`: WGS 84 geographic
  ///    coordinates (longitude, latitude) ordered as specified by
  ///    `AxisOrder.xy`.
  /// * `http://www.opengis.net/def/crs/OGC/1.3/CRS84h`: WGS 84 geographic
  ///    coordinates (longitude, latitude) ordered as specified by
  ///    `AxisOrder.xy`, with ellipsoidal height (elevation) as a third
  ///    coordinate.
  /// * `http://www.opengis.net/def/crs/EPSG/0/4326` or (`EPSG:4326`): WGS 84
  ///    geographic coordinates (latitude, longitude) ordered as specified by
  ///    `AxisOrder.yx`.
  /// * `http://www.opengis.net/def/crs/EPSG/0/4258` or (`EPSG:4258`): ETRS89
  ///    geographic coordinates (latitude, longitude) ordered as specified by
  ///    `AxisOrder.yx`.
  /// * `http://www.opengis.net/def/crs/EPSG/0/3857` or (`EPSG:3857`): WGS 84
  ///    projected (Web Mercator) metric coordinates ordered as specified by
  ///    `AxisOrder.xy`.
  /// * `http://www.opengis.net/def/crs/EPSG/0/3395` or (`EPSG:3395`): WGS 84
  ///    projected (World Mercator) metric coordinates ordered as specified by
  ///    `AxisOrder.xy`.
  ///
  /// The basic implementation of [normalizeId] only normalizes identifiers of
  /// the `EPSG:{code}` template to the
  /// `http://www.opengis.net/def/crs/{authority}/{version}/{code}` template.
  /// Other identifiers are left unmodified when normalizing.
  ///
  /// NOTE: In future the basic implementation is going to be extended to
  /// support also other identifier and more wide normalization logic.
  static CoordRefSysResolver registry = const _BasicCoordRefSysRegistry();

  /// Registers a custom instance of [CoordRefSysResolver], available at
  /// static [registry] after calling this.
  // ignore: use_setters_to_change_properties
  static void register(CoordRefSysResolver resolver) =>
      CoordRefSysResolver.registry = resolver;
}

const _epsgPrefix = 'EPSG:';
const _opengisEPSG0Prefix = 'http://www.opengis.net/def/crs/EPSG/0/';

class _BasicCoordRefSysRegistry implements CoordRefSysResolver {
  const _BasicCoordRefSysRegistry();

  @override
  String normalizeId(String id) {
    if (id.startsWith(_epsgPrefix) && id.length >= _epsgPrefix.length + 1) {
      final code = int.tryParse(id.substring(_epsgPrefix.length));
      if (code != null) {
        return '$_opengisEPSG0Prefix$code';
      }
    }

    return id;
  }

  @override
  bool isGeographic(String id, {bool? wgs84, AxisOrder? order}) {
    final bool idOk;
    switch (id) {
      case 'http://www.opengis.net/def/crs/OGC/1.3/CRS84':
      case 'http://www.opengis.net/def/crs/OGC/1.3/CRS84h':
      case 'http://www.opengis.net/def/crs/EPSG/0/4326':
        // these are all WGS84
        idOk = wgs84 == null || wgs84;
        break;
      case 'http://www.opengis.net/def/crs/EPSG/0/4258':
        // this is not WGS84 but ETRS89
        idOk = wgs84 == null || !wgs84;
        break;
      default:
        idOk = false;
        break;
    }
    if (order != null) {
      return idOk && order == axisOrder(id);
    } else {
      return idOk;
    }
  }

  @override
  AxisOrder? axisOrder(String id) {
    switch (id) {
      case 'http://www.opengis.net/def/crs/OGC/1.3/CRS84':
      case 'http://www.opengis.net/def/crs/OGC/1.3/CRS84h':
        return AxisOrder.xy;
      case 'http://www.opengis.net/def/crs/EPSG/0/4326':
        return AxisOrder.yx;
      case 'http://www.opengis.net/def/crs/EPSG/0/4258':
        return AxisOrder.yx;
      case 'http://www.opengis.net/def/crs/EPSG/0/3857':
        return AxisOrder.xy;
      case 'http://www.opengis.net/def/crs/EPSG/0/3395':
        return AxisOrder.xy;
    }
    return null; // do not know
  }

  @override
  String? epsg(String id) {
    if (id.startsWith(_epsgPrefix) && id.length >= _epsgPrefix.length + 1) {
      final code = int.tryParse(id.substring(_epsgPrefix.length));
      if (code != null) {
        return id;
      }
    }
    if (id.startsWith(_opengisEPSG0Prefix) &&
        id.length >= _opengisEPSG0Prefix.length + 1) {
      final code = int.tryParse(id.substring(_opengisEPSG0Prefix.length));
      if (code != null) {
        return '$_epsgPrefix$code';
      }
    }

    return null; // do not know
  }
}
