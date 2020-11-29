// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

/// An interface for coordinate reference systems.
@immutable
class CRS with EquatableMixin {
  const CRS(this.id, this.name);

  /// Retuns a [CRS] instance for the given [id].
  factory CRS.id(String id) {
    switch (id) {
      case idCRS84:
        return CRS84;
      case idCRS84h:
        return CRS84h;
      default:
        return CRS(id, id);
    }
  }

  /// The official [id] of this CRS.
  ///
  /// For example: `http://www.opengis.net/def/crs/OGC/1.3/CRS84`
  final String id;

  /// The [name] of this CRS.
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// The 'WGS 84 longitude-latitude' coordinate reference system.
// ignore: constant_identifier_names
const CRS84 = CRS(
  idCRS84,
  'WGS 84 longitude-latitude',
);
const idCRS84 = 'http://www.opengis.net/def/crs/OGC/1.3/CRS84';

/// The 'WGS 84 longitude-latitude-height' coordinate reference system.
// ignore: constant_identifier_names
const CRS84h = CRS(
  idCRS84h,
  'WGS 84 longitude-latitude-height',
);
const idCRS84h = 'http://www.opengis.net/def/crs/OGC/0/CRS84h';
