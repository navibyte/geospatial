// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print, cascade_invocations
// ignore_for_file: avoid_redundant_argument_values

import 'package:geobase/geobase.dart';

/*
To test run this from command line: 

dart example/geobase_example.dart
*/

void main() {
  // Coordinates
  _geographicPosition();
  _geographicBbox();
  _projectedPosition();
  _projectedBbox();

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

  // time objects
  _intervalAndInstant();

  // extents
  _geoExtent();

  // projection samples
  _wgs84Projections();

  // transform samples
  _basicTransfroms();
}

void _geographicPosition() {
  // Geographic position with longitude and latitude
  const Geographic(lon: -0.0014, lat: 51.4778);

  // Geographic position with longitude, latitude and elevation.
  const Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0);

  // Geographic position with longitude, latitude, elevation and measure.
  const Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0, m: 123.0);

  // The last sample also from num iterable or text.
  Geographic.fromCoords(const [-0.0014, 51.4778, 45.0, 123.0]);
  Geographic.fromText('-0.0014,51.4778,45.0,123.0');
  Geographic.fromText('-0.0014 51.4778 45.0 123.0', delimiter: ' ');
}

void _geographicBbox() {
  // Geographic bbox (-20.0 .. 20.0 in longitude, 50.0 .. 60.0 in latitude).
  const GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0);

  // Geographic bbox with limits on elevation coordinate too.
  const GeoBox(
    west: -20.0,
    south: 50.0,
    minElev: 100.0,
    east: 20.0,
    north: 60.0,
    maxElev: 200.0,
  );

  // The last sample also from num iterable or text.
  ProjBox.fromCoords(const [-20.0, 50.0, 100.0, 20.0, 60.0, 200.0]);
  ProjBox.fromText('-20.0,50.0,100.0,20.0,60.0,200.0');

  // Geographic bbox with limits on elevation and measure coordinates too.
  const GeoBox(
    west: -20.0,
    south: 50.0,
    minElev: 100.0,
    minM: 5.0,
    east: 20.0,
    north: 60.0,
    maxElev: 200.0,
    maxM: 6.0,
  );
}

void _projectedPosition() {
  // Projected position with x and y.
  const Projected(x: 708221.0, y: 5707225.0);

  // Projected position with x, y and z.
  const Projected(x: 708221.0, y: 5707225.0, z: 45.0);

  // Projected position with x, y, z and m.
  const Projected(x: 708221.0, y: 5707225.0, z: 45.0, m: 123.0);

  // The last sample also from num iterable or text.
  Projected.fromCoords(const [708221.0, 5707225.0, 45.0, 123.0]);
  Projected.fromText('708221.0,5707225.0,45.0,123.0');
  Projected.fromText('708221.0 5707225.0 45.0 123.0', delimiter: ' ');
}

void _projectedBbox() {
  // Projected bbox with limits on x and y.
  const ProjBox(minX: 10, minY: 10, maxX: 20, maxY: 20);

  // Projected bbox with limits on x, y and z.
  const ProjBox(minX: 10, minY: 10, minZ: 10, maxX: 20, maxY: 20, maxZ: 20);

  // The last sample also from num iterable or text.
  ProjBox.fromCoords(const [10, 10, 10, 20, 20, 20]);
  ProjBox.fromText('10,10,10,20,20,20');

  // Projected bbox with limits on x, y, z and m.
  const ProjBox(
    minX: 10,
    minY: 10,
    minZ: 10,
    minM: 10,
    maxX: 20,
    maxY: 20,
    maxZ: 20,
    maxM: 20,
  );
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
        coordinates: const Projected(x: 10.123, y: 20.25),
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
        coordinates: const Projected(x: 10.123, y: 20.25, z: -30.95),
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
        coordinates: const Projected(x: 10.123, y: 20.25, m: -1.999),
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
            const Geographic(lon: 10.123, lat: 20.25, elev: -30.95, m: -1.999),
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
        coordinates: const Geographic(lon: 10.123, lat: 20.25),
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
        coordinates: const Geographic(lon: 10.123, lat: 20.25),
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
    coordinates: const Geographic(lon: 10.123, lat: 20.25),
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
          const Geographic(lon: -1.1, lat: -1.1),
          const Geographic(lon: 2.1, lat: -2.5),
          const Geographic(lon: 3.5, lat: -3.49),
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
                const Geographic(lon: 10.123, lat: 20.25, elev: -30.95),
            coordType: Coords.xyz,
          )
          ..geometryWithPositions2D(
            type: Geom.polygon,
            coordinates: [
              [
                const Geographic(lon: 10.1, lat: 10.1),
                const Geographic(lon: 5, lat: 9),
                const Geographic(lon: 12, lat: 4),
                const Geographic(lon: 10.1, lat: 10.1)
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
          coordinates: const Geographic(lon: 10.123, lat: 20.25),
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
              coordinates: const Geographic(lon: 10.123, lat: 20.25),
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
                const Geographic(lon: -1.1, lat: -1.1),
                const Geographic(lon: 2.1, lat: -2.5),
                const Geographic(lon: 3.5, lat: -3.49),
              ],
            ),
          ),
      )
      ..toString(),
  );
}

void _intervalAndInstant() {
  // Instants can be created from `DateTime` or parsed from text.
  Instant(DateTime.utc(2020, 10, 31, 09, 30));
  Instant.parse('2020-10-31 09:30Z');

  // Intervals (open-started, open-ended, closed).
  Interval.openStart(DateTime.utc(2020, 10, 31));
  Interval.openEnd(DateTime.utc(2020, 10, 01));
  Interval.closed(DateTime.utc(2020, 10, 01), DateTime.utc(2020, 10, 31));

  // Same intervals parsed (by the "start/end" format, ".." for open limits).
  Interval.parse('../2020-10-31');
  Interval.parse('2020-10-01/..');
  Interval.parse('2020-10-01/2020-10-31');
}

void _geoExtent() {
  // An extent with spatial (WGS 84 longitude-latitude) and temporal parts.
  GeoExtent.single(
    crs: 'EPSG:4326',
    bbox: const GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0),
    interval: Interval.parse('../2020-10-31'),
  );

  // An extent with multiple spatial bounds and temporal interval segments.
  GeoExtent.multi(
    crs: 'EPSG:4326',
    boxes: const [
      GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0),
      GeoBox(west: 40.0, south: 50.0, east: 60.0, north: 60.0),
    ],
    intervals: [
      Interval.parse('2020-10-01/2020-10-05'),
      Interval.parse('2020-10-27/2020-10-31'),
    ],
  );
}

void _wgs84Projections() {
  // Built-in coordinate projections (currently only between WGS 84 and
  // Web Mercator)

  // Geographic (WGS 84 longitude-latitude) to Projected (WGS 84 Web Mercator)
  final forward = wgs84ToWebMercator.forward();
  final projected =
      forward.project(const Geographic(lon: -0.0014, lat: 51.4778));

  // Projected (WGS 84 Web Mercator) to Geographic (WGS 84 longitude-latitude)
  final inverse = wgs84ToWebMercator.inverse();
  final unprojected = inverse.project(projected);

  print('$unprojected <=> $projected');
}

void _basicTransfroms() {
  // Create a point and transform it with the built-in translation that returns
  // `Position(x: 110.0, y: 220.0, z: 50.0, m: 1.25)` after transform.
  print(
    const Projected(x: 100.0, y: 200.0, z: 50.0, m: 1.25)
        .transform(translatePosition(dx: 10.0, dy: 20.0)),
  );

  // Create a point and transform it with a custom translation that returns
  // `Position(x: 110.0, y: 220.0, z: 50.0, m: 1.25)` after transform.
  print(
    const Projected(x: 100.0, y: 200.0, z: 50.0, m: 1.25)
        .transform(_sampleFixedTranslate),
  );
}

/// Translates X by 10.0 and Y by 20.0, other coordinates (Z and M) not changed.
T _sampleFixedTranslate<T extends Position>(T source) =>
    source.copyWith(x: source[0] + 10.0, y: source[1] + 20.0) as T;
