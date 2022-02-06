// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print, cascade_invocations

import 'package:geobase/geobase.dart';

/*
To test run this from command line: 

dart example/geobase_example.dart
*/

void main() {
  // WKT samples
  _wktPointGeometry();
  _wktPointGeometryWithZ();
  _wktPointGeometryWithM();
  _wktPointGeometryWithZM();

  // GeoJSON samples
  _geoJsonPointGeometry();
  _geoJsonPointGeometryDecimals();
  _geoJsonPointGeometryCustomStringBuffer();
  _geoJsonLineStringGeometryWithBbox();
  _geoJsonGeometryCollection();
  _geoJsonFeature();
  _geoJsonFeatureCollection();
}

void _wktPointGeometry() {
  // geometry writer for WKT
  final writer = wktFormat().geometriesToText();

  // prints:
  //    POINT(10.123 20.25)
  print(
    writer
      ..geometryWithPosition(
        type: Geom.point,
        coordinates: const Position(x: 10.123, y: 20.25),
      )
      ..toString(),
  );
}

void _wktPointGeometryWithZ() {
  // geometry writer for WKT
  final writer = wktFormat().geometriesToText();

  // prints:
  //    POINT Z(10.123 20.25 -30.95)
  print(
    writer
      ..geometryWithPosition(
        type: Geom.point,
        coordType: Coords.xyz,
        coordinates: const Position(x: 10.123, y: 20.25, z: -30.95),
      )
      ..toString(),
  );
}

void _wktPointGeometryWithM() {
  // geometry writer for WKT
  final writer = wktFormat().geometriesToText();

  // prints:
  //    POINT M(10.123 20.25 -1.999)
  print(
    writer
      ..geometryWithPosition(
        type: Geom.point,
        coordType: Coords.xym,
        coordinates: const Position(x: 10.123, y: 20.25, m: -1.999),
      )
      ..toString(),
  );
}

void _wktPointGeometryWithZM() {
  // geometry writer for WKT
  final writer = wktFormat().geometriesToText();

  // prints:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  print(
    writer
      ..geometryWithPosition(
        type: Geom.point,
        coordType: Coords.xyzm,
        coordinates:
            const GeoPosition(lon: 10.123, lat: 20.25, elev: -30.95, m: -1.999),
      )
      ..toString(),
  );
}

void _geoJsonPointGeometry() {
  // geometry writer for GeoJSON
  final writer = geoJsonFormat().geometriesToText();

  // prints:
  //    {"type":"Point","coordinates":[10.123,20.25]}
  print(
    writer
      ..geometryWithPosition(
        type: Geom.point,
        coordinates: const GeoPosition(lon: 10.123, lat: 20.25),
      )
      ..toString(),
  );
}

void _geoJsonPointGeometryDecimals() {
  // geometry writer for GeoJSON, with number of decimals for text output set
  final writer = geoJsonFormat().geometriesToText(decimals: 1);

  // prints:
  //    {"type":"Point","coordinates":[10.1,20.3]}
  print(
    writer
      ..geometryWithPosition(
        type: Geom.point,
        coordinates: const GeoPosition(lon: 10.123, lat: 20.25),
      )
      ..toString(),
  );
}

void _geoJsonPointGeometryCustomStringBuffer() {
  // geometry writer for GeoJSON with a custom string buffer
  final buf = StringBuffer();
  final writer = geoJsonFormat().geometriesToText(buffer: buf);

  // write both directly to buffer and via geometry writer
  buf.write('{"geometry":');
  writer.geometryWithPosition(
    type: Geom.point,
    coordinates: const GeoPosition(lon: 10.123, lat: 20.25),
  );
  buf.write('}');

  // prints:
  //    {"geometry":{"type":"Point","coordinates":[10.123,20.25]}}
  print(buf.toString());
}

void _geoJsonLineStringGeometryWithBbox() {
  // geometry writer for GeoJSON
  final writer = geoJsonFormat().geometriesToText();

  // prints (however without line breaks):
  //    {"type":"LineString",
  //     "bbox":[-1.1,-3.49,3.5,-1.1],
  //     "coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]}
  print(
    writer
      ..geometryWithPositions1D(
        type: Geom.lineString,
        bbox: const GeoBox(west: -1.1, south: -3.49, east: 3.5, north: -1.1),
        coordinates: [
          const GeoPosition(lon: -1.1, lat: -1.1),
          const GeoPosition(lon: 2.1, lat: -2.5),
          const GeoPosition(lon: 3.5, lat: -3.49),
        ],
      )
      ..toString(),
  );
}

void _geoJsonGeometryCollection() {
  // geometry writer for GeoJSON
  final writer = geoJsonFormat().geometriesToText();

  // prints (however without line breaks):
  //    {"type":"GeometryCollection",
  //     "geometries":[
  //        {"type":"Point",
  //         "coordinates":[10.123,20.25,-30.95]},
  //        {"type":"Polygon",
  //         "coordinates":[[[10.1,10.1],[5,9],[12,4],[10.1,10.1]]]}]}
  print(
    writer
      ..geometryCollection(
        geometries: (gw) => gw
          ..geometryWithPosition(
            type: Geom.point,
            coordinates:
                const GeoPosition(lon: 10.123, lat: 20.25, elev: -30.95),
            coordType: Coords.xyz,
          )
          ..geometryWithPositions2D(
            type: Geom.polygon,
            coordinates: [
              [
                const GeoPosition(lon: 10.1, lat: 10.1),
                const GeoPosition(lon: 5, lat: 9),
                const GeoPosition(lon: 12, lat: 4),
                const GeoPosition(lon: 10.1, lat: 10.1)
              ],
            ],
          ),
      )
      ..toString(),
  );
}

void _geoJsonFeature() {
  // feature writer for GeoJSON
  final writer = geoJsonFormat().featuresToText();

  // prints (however without line breaks):
  //    {"type":"Feature",
  //     "id":"fid-1",
  //     "geometry":
  //        {"type":"Point","coordinates":[10.123,20.25]},
  //     "properties":
  //        {"foo":100,"bar":"this is property value","baz":true}}
  print(
    writer
      ..feature(
        id: 'fid-1',
        geometries: (gw) => gw.geometryWithPosition(
          type: Geom.point,
          coordinates: const GeoPosition(lon: 10.123, lat: 20.25),
        ),
        properties: {
          'foo': 100,
          'bar': 'this is property value',
          'baz': true,
        },
      )
      ..toString(),
  );
}

void _geoJsonFeatureCollection() {
  // feature writer for GeoJSON
  final writer = geoJsonFormat().featuresToText();

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
  print(
    writer
      ..featureCollection(
        bbox: const GeoBox(
          west: -1.1,
          south: -3.49,
          east: 10.123,
          north: 20.25,
        ),
        features: (fw) => fw
          ..feature(
            id: 'fid-1',
            geometries: (gw) => gw.geometryWithPosition(
              type: Geom.point,
              coordinates: const GeoPosition(lon: 10.123, lat: 20.25),
            ),
            properties: {
              'foo': 100,
              'bar': 'this is property value',
            },
          )
          ..feature(
            geometries: (gw) => gw.geometryWithPositions1D(
              type: Geom.lineString,
              bbox: const GeoBox(
                west: -1.1,
                south: -3.49,
                east: 3.5,
                north: -1.1,
              ),
              coordinates: [
                const GeoPosition(lon: -1.1, lat: -1.1),
                const GeoPosition(lon: 2.1, lat: -2.5),
                const GeoPosition(lon: 3.5, lat: -3.49),
              ],
            ),
          ),
      )
      ..toString(),
  );
}
