// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:geocore/geocore.dart';

import '../../../model/geo/common.dart';
import '../../../model/geo/features.dart';

/// Parses a "/collections/{id}/items" feature items from a OGC API service.
FeatureItems featuresItemsFromJson(Map<String, dynamic> json) {
  if (json['type'] != 'FeatureCollection') {
    throw FormatException('Not valid GeoJSON FeatureCollection.');
  }
  return FeatureItems(
    meta: ItemsMeta(
      timeStamp: DateTime.now(),
      numberMatched: json['numberMatched'],
      numberReturned: json['numberReturned'],
    ),
    all: _featuresFromJson(json['features']),
  );
}

/// Parses a feature collection from GeoJSON content.
FeatureSeries _featuresFromJson(List json) {
  return FeatureSeries.from(json.map<Feature>(
    (feature) {
      if (feature['type'] != 'Feature') {
        throw FormatException('Not valid GeoJSON Feature.');
      }
      return Feature.of(
          id: feature['id'],
          geometry: _geometryFromJson(feature['geometry']),
          properties: feature['properties']);
    },
  ));
}

Geometry _geometryFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'Point':
      final coords = json['coordinates'];
      if (coords.length >= 3) {
        return GeoPoint3.lonLatElev(
          valueToDouble(coords[0]),
          valueToDouble(coords[1]),
          valueToDouble(coords[2]),
        );
      } else if (coords.length >= 2) {
        return GeoPoint2.lonLat(
          valueToDouble(coords[0]),
          valueToDouble(coords[1]),
        );
      }
      break;

    // TODO: all other geometry types ....
  }
  // did not recognize, return empty geometry
  return Point.empty();
}
