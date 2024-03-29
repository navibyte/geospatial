// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print, cascade_invocations

// import the default geobase library
import 'package:geobase/geobase.dart';

// need also an additional import with dependency to `proj4dart`
import 'package:geobase/projections_proj4d.dart';

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

  // The projection adapter between WGS84 (CRS84) and EPSG:23700 (definition)
  // (based on the sample at https://pub.dev/packages/proj4dart).
  final adapter = Proj4d.init(
    CoordRefSys.CRS84,
    CoordRefSys.normalized('EPSG:23700'),
    targetDef: '+proj=somerc +lat_0=47.14439372222222 +lon_0=19.04857177777778 '
        '+k_0=0.99993 +x_0=650000 +y_0=200000 +ellps=GRS67 '
        '+towgs84=52.17,-71.82,-14.9,0,0,0,0 +units=m +no_defs',
  );

  // The forward projection from WGS84 (CRS84) to EPSG:23700.
  final forward = adapter.forward;

  // A source geographic position.
  const geographic = Geographic(lat: 46.8922, lon: 17.8880);

  // Apply the forward projection returning a projected position in EPSG:23700.
  final projected = geographic.project(forward);

  // Prints: "561647.27300,172651.56518"
  print(projected.toText(decimals: 5));
}
