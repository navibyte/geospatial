// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:geocore/parse_geojson.dart';

import '../../../model/geo/common.dart';
import '../../../model/geo/features.dart';

/// Parses a "/collections/{id}/items" feature items from a OGC API service.
FeatureItems featureItemsFromJson(Map<String, dynamic> json) => FeatureItems(
      collection: geoJSON.featureCollection(json),
      meta: ItemsMeta(
        timeStamp: DateTime.now(),
        numberMatched: json['numberMatched'],
        numberReturned: json['numberReturned'],
      ),
    );
