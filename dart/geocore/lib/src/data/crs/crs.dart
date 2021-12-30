// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

/// The type of the coordinate reference system.
@Deprecated('CRS sub package deprecated from 0.8.0')
enum CRSType {
  /// Coordinates of [geographic] crs are decimal degrees (longitude, latitude).
  geographic,

  /// Coordinates of [projected] crs are defined by a datum and units of a crs.
  projected,

  /// Coordinates of [local] crs are specified by some local system.
  local
}

/// A coordinate reference system.
///
/// See [Coordinate Reference Systems](https://www.w3.org/2015/spatial/wiki/Coordinate_Reference_Systems)
/// by W3C.
@Deprecated('CRS sub package deprecated from 0.8.0')
@immutable
class CRS with EquatableMixin {
  /// Create a crs of [id], [name] and [type].
  @Deprecated('CRS sub package deprecated from 0.8.0')
  const CRS(this.id, this.name, this.type);

  /// Returns a [CRS] instance for a CRS by [id].
  @Deprecated('CRS sub package deprecated from 0.8.0')
  factory CRS.id(String id, {CRSType type = CRSType.geographic}) {
    switch (id) {
      case idCRS84:
        return CRS84;
      case idCRS84h:
        return CRS84h;
      default:
        return CRS(id, id, type);
    }
  }

  /// The official [id] of this CRS.
  ///
  /// For example: `http://www.opengis.net/def/crs/OGC/1.3/CRS84`
  final String id;

  /// The [name] of this CRS.
  final String name;

  /// Type [type] of this CRS.
  final CRSType type;

  @override
  List<Object?> get props => [id, name, type];
}

/// The 'WGS 84 longitude-latitude' coordinate reference system.
///
/// This crs is assumed as a default for 2D geographic coordinates if nothing
/// else is specified.
@Deprecated('CRS sub package deprecated from 0.8.0')
// ignore: constant_identifier_names
const CRS84 = CRS(
  idCRS84,
  'WGS 84 longitude-latitude',
  CRSType.geographic,
);

/// The `CRS80` identifier.
@Deprecated('CRS sub package deprecated from 0.8.0')
const idCRS84 = 'http://www.opengis.net/def/crs/OGC/1.3/CRS84';

/// The 'WGS 84 longitude-latitude-height' coordinate reference system.
///
/// This crs is assumed as a default for 3D geographic coordinates if nothing
/// else is specified.
@Deprecated('CRS sub package deprecated from 0.8.0')
// ignore: constant_identifier_names
const CRS84h = CRS(
  idCRS84h,
  'WGS 84 longitude-latitude-height',
  CRSType.geographic,
);

/// The `CRS80h` identifier.
@Deprecated('CRS sub package deprecated from 0.8.0')
const idCRS84h = 'http://www.opengis.net/def/crs/OGC/0/CRS84h';
