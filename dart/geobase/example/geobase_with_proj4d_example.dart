// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print, cascade_invocations

import 'package:geobase/with_proj4d.dart';

/*
To test run this from command line: 

dart example/geobase_with_proj4d_example.dart
*/

void main() {
  // projection samples
  _proj4projections();
}

void _proj4projections() {
  // Coordinate projections based on the external proj4dart package.

  // A projection adapter from WGS84 (EPSG:4326) to EPSG:23700 (with definition)
  // (based on the sample at https://pub.dev/packages/proj4dart).
  final adapter = proj4dart(
    'EPSG:4326',
    'EPSG:23700',
    toDef: '+proj=somerc +lat_0=47.14439372222222 +lon_0=19.04857177777778 '
        '+k_0=0.99993 +x_0=650000 +y_0=200000 +ellps=GRS67 '
        '+towgs84=52.17,-71.82,-14.9,0,0,0,0 +units=m +no_defs',
  );

  // Apply a forward projection to EPSG:23700 with points represented as Point2.
  final forward = adapter.forward();
  print(forward.project(const Geographic(lon: 17.8880, lat: 46.8922)));
}
