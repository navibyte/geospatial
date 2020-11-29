// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import 'package:geocore/base.dart';

import 'items.dart';

/// A geospatial feature collection.
abstract class Features extends Items<Feature, ItemsMeta> {}

/// A geospatial feature.
///
/// Supports representing data from GeoJSON (https://geojson.org/) features.
@immutable
class Feature extends Item with EquatableMixin {
  const Feature(
      {required this.id, required this.geometry, this.properties = const {}});

  /// The [id] for this feature.
  final String id;

  /// The [geometry] for this feature.
  final Geometry geometry;

  /// Properties for this feature, allowed to be empty.
  final Map<String, Object> properties;

  @override
  List<Object?> get props => [id, geometry, properties];
}
