// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print, cascade_invocations
// ignore_for_file: avoid_redundant_argument_values, prefer_asserts_with_message

import 'package:geobase/geobase.dart';

/*
To test run this from command line: 

dart example/geobase_old_example.dart
*/

void main() {
  // WKT samples
  print('\nWKT samples');
  _wktPointGeometry();
  _wktPointGeometryWithZ();
  _wktPointGeometryWithM();
  _wktPointGeometryWithZM();
  _wktPointGeometryWithZMShortened();

  // GeoJSON samples
  print('\nGeoJSON samples');
  _geoJsonPointGeometry();
  _geoJsonPointGeometryDecimals();
  _geoJsonPointGeometryCustomStringBuffer();
  _geoJsonLineStringGeometryWithBbox();
  _geoJsonGeometryCollection();
  _geoJsonFeature();
  _geoJsonFeatureCollection();
}

void _wktPointGeometry() {
  // geometry text format encoder for WKT
  final encoder = WKT.geometry.encoder();

  // prints:
  //    POINT(10.123 20.25)
  encoder.writer.point([10.123, 20.25]);
  print(encoder.toText());
}

void _wktPointGeometryWithZ() {
  // geometry text format encoder for WKT
  final encoder = WKT.geometry.encoder();

  // prints:
  //    POINT Z(10.123 20.25 -30.95)
  encoder.writer.point(
    [10.123, 20.25, -30.95],
    type: Coords.xyz,
  );
  print(encoder.toText());
}

void _wktPointGeometryWithM() {
  // geometry text format encoder for WKT
  final encoder = WKT.geometry.encoder();

  // prints:
  //    POINT M(10.123 20.25 -1.999)
  encoder.writer.point(
    [10.123, 20.25, -1.999],
    type: Coords.xym,
  );
  print(encoder.toText());
}

void _wktPointGeometryWithZM() {
  // geometry text format encoder for WKT
  final encoder = WKT.geometry.encoder();

  // prints:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  encoder.writer.point(
    [10.123, 20.25, -30.95, -1.999].xyzm,
    type: Coords.xyzm,
  );
  print(encoder.toText());
}

void _wktPointGeometryWithZMShortened() {
  // geometry text format encoder for WKT
  final encoder = WKT.geometry.encoder();

  // prints:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  encoder.writer.point(
    [10.123, 20.25, -30.95, -1.999],
    type: Coords.xyzm,
  );
  print(encoder.toText());
}

void _geoJsonPointGeometry() {
  // geometry text format encoder for GeoJSON
  final encoder = GeoJSON.geometry.encoder();

  // prints:
  //    {"type":"Point","coordinates":[10.123,20.25]}
  encoder.writer.point([10.123, 20.25]);
  print(encoder.toText());
}

void _geoJsonPointGeometryDecimals() {
  // geometry encoder for GeoJSON, with number of decimals for text output set
  final encoder = GeoJSON.geometry.encoder(decimals: 1);

  // prints:
  //    {"type":"Point","coordinates":[10.1,20.3]}
  encoder.writer.point([10.123, 20.25]);
  print(encoder.toText());
}

void _geoJsonPointGeometryCustomStringBuffer() {
  // geometry text format encoder for GeoJSON with a custom string buffer
  final buf = StringBuffer();
  final encoder = GeoJSON.geometry.encoder(buffer: buf);

  // write both directly to buffer and via geometry writer
  buf.write('{"geometry":');
  encoder.writer.point([10.123, 20.25]);
  buf.write('}');

  // prints:
  //    {"geometry":{"type":"Point","coordinates":[10.123,20.25]}}
  print(buf);
}

void _geoJsonLineStringGeometryWithBbox() {
  // geometry text format encoder for GeoJSON
  final encoder = GeoJSON.geometry.encoder();

  // prints (however without line breaks):
  //    {"type":"LineString",
  //     "bbox":[-1.1,-3.49,3.5,-1.1],
  //     "coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]}
  encoder.writer.lineString(
    [-1.1, -1.1, 2.1, -2.5, 3.5, -3.49],
    type: Coords.xy,
    bounds: [-1.1, -3.49, 3.5, -1.1],
  );
  print(encoder.toText());
}

void _geoJsonGeometryCollection() {
  // geometry text format encoder for GeoJSON
  final encoder = GeoJSON.geometry.encoder();

  // prints (however without line breaks):
  //    {"type":"GeometryCollection",
  //     "geometries":[
  //        {"type":"Point",
  //         "coordinates":[10.123,20.25,-30.95]},
  //        {"type":"Polygon",
  //         "coordinates":[[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]]]}]}

  encoder.writer.geometryCollection(
    // optional `count` argument is used to hint encoder of number of items
    // (this may allow an encoder to optimize writing optimal array structure)
    count: 2,
    // callback function to write geometry items, geom is SimpleGeometryContent
    (geom) => geom
      ..point([10.123, 20.25, -30.95], type: Coords.xyz)
      ..polygon(
        [
          [10.1, 10.1, 5, 9, 12, 4, 10.1, 10.1],
        ],
        type: Coords.xy,
      ),
  );
  print(encoder.toText());
}

void _geoJsonFeature() {
  // feature text format encoder for GeoJSON
  final encoder = GeoJSON.feature.encoder();

  // prints (however without line breaks):
  //    {"type":"Feature",
  //     "id":"fid-1",
  //     "geometry":
  //        {"type":"Point","coordinates":[10.123,20.25]},
  //     "properties":
  //        {"foo":100,"bar":"this is property value","baz":true}}
  encoder.writer.feature(
    id: 'fid-1',
    geometry: (geom) => geom.point([10.123, 20.25]),
    properties: {
      'foo': 100,
      'bar': 'this is property value',
      'baz': true,
    },
  );
  print(encoder.toText());
}

void _geoJsonFeatureCollection() {
  // feature text format encoder for GeoJSON
  final encoder = GeoJSON.feature.encoder();

  // prints (however without line breaks):
  //    {"type":"FeatureCollection",
  //     "bbox":[-1.1,-3.49,10.123,20.25],
  //     "features":[
  //        {"type":"Feature",
  //         "id":"fid-1",
  //         "geometry":{"type":"Point","coordinates":[10.123,20.25]},
  //         "properties":{"foo":100,"bar":"this is property value"}},
  //        {"type":"Feature",
  //         "geometry":{"type":"LineString",
  //                     "bbox":[-1.1,-3.49,3.5,-1.1],
  //                     "coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]},
  //         "properties":{}}]}
  encoder.writer.featureCollection(
    // bbox covering the whole feature collection
    bounds: [-1.1, -3.49, 10.123, 20.25],
    count: 2, // expected feature count
    (features) => features // writing to FeatureContent
      ..feature(
        id: 'fid-1',
        geometry: (geom) => geom.point([10.123, 20.25]),
        properties: {
          'foo': 100,
          'bar': 'this is property value',
        },
      )
      ..feature(
        geometry: (geom) => geom.lineString(
          [-1.1, -1.1, 2.1, -2.5, 3.5, -3.49],
          type: Coords.xy,
          bounds: [-1.1, -3.49, 3.5, -1.1],
        ),
      ),
  );
  print(encoder.toText());
}
