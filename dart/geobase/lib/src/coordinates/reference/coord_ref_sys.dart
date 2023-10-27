// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: constant_identifier_names

import 'package:meta/meta.dart';

import '/src/common/codes/axis_order.dart';
import '/src/common/codes/geo_representation.dart';

import 'coord_ref_sys_resolver.dart';

/// Metadata about a coordinate reference system (CRS) identified and specified
/// by [id].
///
/// NOTE: The current version of this class does not yet provide very much CRS
/// metadata, but in future this might also provide more information.
@immutable
class CoordRefSys {
  /// Metadata about a coordinate reference system (CRS) identified and
  /// specified by [id].
  ///
  /// No normalization of identifiers is done, so for example
  /// `CoordRefSys.id('http://www.opengis.net/def/crs/EPSG/0/4326')` and
  /// `CoordRefSys.id('EPSG:4326')` would be different instances even if
  /// referring to the same coordinate reference system (WGS84
  /// latitude/longitude).
  ///
  /// See also [CoordRefSys.normalized].
  const CoordRefSys.id(this.id);

  /// Metadata about a coordinate reference system (CRS) identified and
  /// specified by the normalized identifier of [id].
  ///
  /// Normalization: `CoordRefSysResolver.registry.normalizeId(id)`.
  ///
  /// Using the basic default implementation of CoordRefSysResolver
  /// `CoordRefSys.normalized('http://www.opengis.net/def/crs/EPSG/0/4326')` and
  /// `CoordRefSys.normalized('EPSG:4326')` would refer to the same instance
  /// with id normalized as `http://www.opengis.net/def/crs/EPSG/0/4326`.
  CoordRefSys.normalized(String id)
      : id = CoordRefSysResolver.registry.normalizeId(id);

  /// The coordinate reference system (CRS) identifier.
  ///
  /// The identifier is authorative, it identifies a well known or referenced
  /// specification that defines properties for a coordinate reference system.
  ///
  /// Examples:
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
  final String id;

  /// Returns true if coordinate reference system identified by [id] represents
  /// geographic coordinates.
  ///
  /// Optionally check also that the axis order equals to given axis [order] or
  /// that geographic coordinates are based on the WGS 84 datum.
  bool isGeographic({bool? wgs84, AxisOrder? order}) =>
      CoordRefSysResolver.registry.isGeographic(id, wgs84: wgs84, order: order);

  /// Try to resolve the axis order (as a CRS authority has specified it) of
  /// coordinate values in position and point representations for this
  /// coordinate reference system identified by [id].
  ///
  /// The `null` return value is interpreted as "the axis order is not known".
  AxisOrder? get axisOrder => CoordRefSysResolver.registry.axisOrder(id);

  /// Whether x and y coordinates read from (or written to) external data
  /// representation should be swapped for the coordinate reference system
  /// identified by [id] before using in internal data structures of this
  /// package.
  ///
  /// Use [logic] to give general guidelines how a result is to be resolved.
  /// When not given `GeoRepresentation.crsAuthority` is used as a default.
  bool swapXY({GeoRepresentation? logic}) =>
      CoordRefSysResolver.registry.swapXY(id, logic: logic);

  /// Returns an EPSG identifier according to the common `EPSG:{code}` template
  /// for [id] if the coordinate reference system is recognized by the
  /// [EPSG register](https://epsg.org/).
  ///
  /// For example for `http://www.opengis.net/def/crs/EPSG/0/4326` (WGS 84
  /// latitude/longitude) this getter returns `EPSG:4326`, but for
  /// `http://www.opengis.net/def/crs/OGC/1.3/CRS84` this returns null as CRS84
  /// (WGS 84 longitude/latitude) do not have an exact corresponding identifier
  /// in the EPSG register.
  String? get epsg => CoordRefSysResolver.registry.epsg(id);

  /// The coordinate reference system resolved in this order:
  /// 1. [coordRefSys] if it's non-null
  /// 2. otherwise `CoordRefSys.normalized(crs)` if [crs] is non-null
  /// 3. otherwise `CoordRefSys.CRS84`
  factory CoordRefSys.from({
    CoordRefSys? coordRefSys,
    String? crs,
  }) =>
      coordRefSys ?? (crs != null ? CoordRefSys.normalized(crs) : CRS84);

  /// The coordinate reference system identified by
  /// 'http://www.opengis.net/def/crs/OGC/1.3/CRS84'.
  ///
  /// References WGS 84 geographic coordinates (longitude, latitude) ordered as
  /// specified by `AxisOrder.xy`.
  static const CoordRefSys CRS84 =
      CoordRefSys.id('http://www.opengis.net/def/crs/OGC/1.3/CRS84');

  /// The coordinate reference system identified by
  /// 'http://www.opengis.net/def/crs/OGC/1.3/CRS84h'.
  ///
  /// References WGS 84 geographic coordinates (longitude, latitude) ordered as
  /// specified by `AxisOrder.xy`, with ellipsoidal height (elevation) as a
  /// third coordinate.
  static const CoordRefSys CRS84h =
      CoordRefSys.id('http://www.opengis.net/def/crs/OGC/1.3/CRS84h');

  /// The coordinate reference system identified by
  /// 'http://www.opengis.net/def/crs/EPSG/0/4326'.
  ///
  /// References WGS 84 geographic coordinates (latitude, longitude) ordered as
  /// specified by `AxisOrder.yx`.
  static const CoordRefSys EPSG_4326 =
      CoordRefSys.id('http://www.opengis.net/def/crs/EPSG/0/4326');

  /// The coordinate reference system identified by
  /// 'http://www.opengis.net/def/crs/EPSG/0/4258'.
  ///
  /// References ETRS89 geographic coordinates (latitude, longitude) ordered as
  /// specified by `AxisOrder.yx`.
  static const CoordRefSys EPSG_4258 =
      CoordRefSys.id('http://www.opengis.net/def/crs/EPSG/0/4258');

  /// The coordinate reference system identified by
  /// 'http://www.opengis.net/def/crs/EPSG/0/3857'.
  ///
  /// References WGS 84 projected (Web Mercator) metric coordinates ordered as
  /// specified by `AxisOrder.xy`.
  ///
  /// Also known as WGS 84 / Pseudo-Mercator. Uses "spherical development of
  /// ellipsoidal coordinates".
  static const CoordRefSys EPSG_3857 =
      CoordRefSys.id('http://www.opengis.net/def/crs/EPSG/0/3857');

  /// The coordinate reference system identified by
  /// 'http://www.opengis.net/def/crs/EPSG/0/3395'.
  ///
  /// References WGS 84 projected (World Mercator) metric coordinates ordered as
  /// specified by `AxisOrder.xy`.
  static const CoordRefSys EPSG_3395 =
      CoordRefSys.id('http://www.opengis.net/def/crs/EPSG/0/3395');

  @override
  String toString() => id;

  @override
  bool operator ==(Object other) => other is CoordRefSys && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
