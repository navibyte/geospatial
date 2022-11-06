// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, cascade_invocations, lines_longer_than_80_chars, avoid_redundant_argument_values

import 'package:geobase/geobase.dart';

/*
To test run this from command line: 

dart example/geobase_example.dart
*/

void main() {
  // coordinates
  _geographicCoordinates();
  _projectedCoordinates();
  _scalableCoordinates();

  // coordinate arrays
  _coordinateArrays();

  // geometries
  _geometryTypes2D();
  _point();
  _lineString();
  _polygon();
  _multiPoint();
  _multiLineString();
  _multiPolygon();
  _geometryCollection();

  // geospatial features
  _feature();
  _featureCollection();

  // meta
  _temporalData();
  _geospatialExtents();

  // vector data
  _geoJson();
  _wkt();
  _wkbSample1();
  _wkbSample2();

  // projections
  _wgs84ToWebMercator();
  // see also separate file "geobase_with_proj4d_example.dart"

  // tiling schemes
  _webMercatorQuad();
  _globalGeodeticQuad();
}

void _geographicCoordinates() {
  // A geographic position with longitude and latitude.
  Geographic(lon: -0.0014, lat: 51.4778);

  // A geographic position with longitude, latitude and elevation.
  Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0);

  // A geographic position with longitude, latitude, elevation and measure.
  Geographic(lon: -0.0014, lat: 51.4778, elev: 45.0, m: 123.0);

  // The last sample also from a double list or text (order: lon, lat, elev, m).
  Geographic.build([-0.0014, 51.4778, 45.0, 123.0]);
  Geographic.parse('-0.0014,51.4778,45.0,123.0');
  Geographic.parse('-0.0014 51.4778 45.0 123.0', delimiter: ' ');

  // -------

  // A geographic bbox (-20 .. 20 in longitude, 50 .. 60 in latitude).
  GeoBox(west: -20, south: 50, east: 20, north: 60);

  // A geographic bbox with limits (100 .. 200) on the elevation coordinate too.
  GeoBox(west: -20, south: 50, minElev: 100, east: 20, north: 60, maxElev: 200);

  // The last sample also from a double list or text.
  GeoBox.build([-20, 50, 100, 20, 60, 200]);
  GeoBox.parse('-20,50,100,20,60,200');
}

void _projectedCoordinates() {
  // A projected position with x and y.
  Projected(x: 708221.0, y: 5707225.0);

  // A projected position with x, y and z.
  Projected(x: 708221.0, y: 5707225.0, z: 45.0);

  // A projected position with x, y, z and m.
  Projected(x: 708221.0, y: 5707225.0, z: 45.0, m: 123.0);

  // The last sample also from a double list or text (order: x, y, z, m).
  Projected.build([708221.0, 5707225.0, 45.0, 123.0]);
  Projected.parse('708221.0,5707225.0,45.0,123.0');
  Projected.parse('708221.0 5707225.0 45.0 123.0', delimiter: ' ');

  // -------

  // A projected bbox with limits on x and y.
  ProjBox(minX: 10, minY: 10, maxX: 20, maxY: 20);

  // A projected bbox with limits on x, y and z.
  ProjBox(minX: 10, minY: 10, minZ: 10, maxX: 20, maxY: 20, maxZ: 20);

  // The last sample also from a double list or text.
  ProjBox.build([10, 10, 10, 20, 20, 20]);
  ProjBox.parse('10,10,10,20,20,20');
}

void _scalableCoordinates() {
  // A pixel with a zoom level (or LOD = level of detail) coordinates.
  const pixel = Scalable2i(zoom: 9, x: 23, y: 10);

  // Such coordinates can be scaled to other zoom levels.
  pixel.zoomIn(); // => Scalable2i(zoom: 10, x: 46, y: 20);
  pixel.zoomOut(); // => Scalable2i(zoom: 8, x: 11, y: 5);
  pixel.zoomTo(13); // => Scalable2i(zoom: 13, x: 368, y: 160));
}

void _coordinateArrays() {
  // A position array with three positions each with x and y coordinates.
  PositionArray.view(
    [
      10.0, 11.0, // (x, y) for position 0
      20.0, 21.0, // (x, y) for position 1
      30.0, 31.0, // (x, y) for position 2
    ],
    type: Coords.xy,
  );

  // A position array with three positions each with x, y and z coordinates.
  PositionArray.view(
    [
      10.0, 11.0, 12.0, // (x, y, z) for position 0
      20.0, 21.0, 22.0, // (x, y, z) for position 1
      30.0, 31.0, 32.0, // (x, y, z) for position 2
    ],
    type: Coords.xyz,
  );
}

void _geometryTypes2D() {
  // point (with a position)
  Point.build([30.0, 10.0]);
  Point(XY(30.0, 10.0));

  // line string (with a chain)
  LineString.build([30, 10, 10, 30, 40, 40]);

  // polygon (with an exterior ring)
  Polygon.build([
    [30, 10, 40, 40, 20, 40, 10, 20, 30, 10],
  ]);

  // polygon (with an exterior ring and one interior ring as a hole)
  Polygon.build(
    [
      [35, 10, 45, 45, 15, 40, 10, 20, 35, 10],
      [20, 30, 35, 35, 30, 20, 20, 30],
    ],
  );

  // multi point (with four points)
  MultiPoint.build(
    [
      [10, 40],
      [40, 30],
      [20, 20],
      [30, 10],
    ],
  );

  // multi line string (with two line strings)
  MultiLineString.build(
    [
      [10, 10, 20, 20, 10, 40],
      [40, 40, 30, 30, 40, 20, 30, 10],
    ],
  );

  // multi polygon (with two polygons)
  MultiPolygon.build(
    [
      [
        [30, 20, 45, 40, 10, 40, 30, 20],
      ],
      [
        [15, 5, 40, 10, 10, 20, 5, 10, 15, 5],
      ],
    ],
  );

  // multi polygon (with one polygon without a hole, and another with a hole)
  MultiPolygon.build(
    [
      [
        [40, 40, 20, 45, 45, 30, 40, 40],
      ],
      [
        [20, 35, 10, 30, 10, 10, 30, 5, 45, 20, 20, 35],
        [30, 20, 20, 15, 20, 25, 30, 20],
      ],
    ],
  );

  // geometry collection (with point, line string and polygon geometries)
  GeometryCollection([
    Point.build([30.0, 10.0]),
    LineString.build([10, 10, 20, 20, 10, 40]),
    Polygon.build([
      [40, 40, 20, 45, 45, 30, 40, 40],
    ])
  ]);
}

/*
void _geometryTypesOneliners() {
  // same samples as in "_geometryTypes" but formatted to fit README table

  // point (with a position)
  Point.build([30.0, 10.0]);
  Point(XY(30.0, 10.0));

  // line string (with a chain)
  LineString.build([30, 10, 10, 30, 40, 40]);

  // polygon (with an exterior ring)
  Polygon.build([[30, 10, 40, 40, 20, 40, 10, 20, 30, 10]]);

  // polygon (with an exterior ring and one interior ring as a hole)
  Polygon.build([[35, 10, 45, 45, 15, 40, 10, 20, 35, 10], [20, 30, 35, 35, 30, 20, 20, 30]]);

  // multi point (with four points)
  MultiPoint.build([[10, 40], [40, 30], [20, 20], [30, 10]]);

  // multi line string (with two line strings)
  MultiLineString.build([[10, 10, 20, 20, 10, 40], [40, 40, 30, 30, 40, 20, 30, 10]]);

  // multi polygon (with two polygons)
  MultiPolygon.build([[[30, 20, 45, 40, 10, 40, 30, 20]], [[15, 5, 40, 10, 10, 20, 5, 10, 15, 5]]]);

  // multi polygon (with one polygon without a hole, and another with a hole)
  MultiPolygon.build([[[40, 40, 20, 45, 45, 30, 40, 40]], [[20, 35, 10, 30, 10, 10, 30, 5, 45, 20, 20, 35], [30, 20, 20, 15, 20, 25, 30, 20]]]);

  // geometry collection (with point, line string and polygon geometries)
  GeometryCollection([Point.build([30.0, 10.0]), LineString.build([10, 10, 20, 20, 10, 40], type: Coords.xy), Polygon.build([[40, 40, 20, 45, 45, 30, 40, 40]])]);
}
*/

void _point() {}

void _lineString() {}

void _polygon() {}

void _multiPoint() {}

void _multiLineString() {}

void _multiPolygon() {}

void _geometryCollection() {}

void _feature() {
  // A geospatial feature with id, a point geometry and properties.
  Feature(
    id: 'ROG',
    // a point geometry with a position (lon, lat, elev)
    geometry: Point.build([-0.0014, 51.4778, 45.0]),
    properties: {
      'title': 'Royal Observatory',
      'place': 'Greenwich',
      'city': 'London',
      'isMuseum': true,
      'measure': 5.79,
    },
  );
}

void _featureCollection() {
  // A geospatial feature collection (with two features):
  FeatureCollection([
    Feature(
      id: 'ROG',
      geometry: Point(LonLatElev(-0.0014, 51.4778, 45.0)),
      properties: {
        'title': 'Royal Observatory',
        'place': 'Greenwich',
        'city': 'London',
        'isMuseum': true,
        'measure': 5.79,
      },
    ),
    Feature(
      id: 'TB',
      geometry: Point(LonLat(-0.075406, 51.5055)),
      properties: {
        'title': 'Tower Bridge',
        'city': 'London',
        'built': 1886,
      },
    ),
  ]);
}

void _geoJson() {
  // build a LineString sample geometry
  final lineString = LineString.build(
    [-1.1, -1.1, 2.1, -2.5, 3.5, -3.49],
    type: Coords.xy,
    bounds: [-1.1, -3.49, 3.5, -1.1],
  );

  // ... and print it as GeoJSON text:
  //   {
  //     "type":"LineString",
  //     "bbox":[-1.1,-3.49,3.5,-1.1],
  //     "coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]
  //   }
  print(lineString.toText(format: GeoJSON.geometry));

  // GeoJSON representation for other geometries, features and feature
  // collections can be produced with `toText` methdod also.

  // here a Feature is printed as GeoJSON text (with 3 decimals on doubles):
  //   {
  //     "type":"Feature",
  //     "id":"TB",
  //     "geometry":{"type":"Point","coordinates":[-0.075,51.505]},
  //     "properties":{"title":"Tower Bridge","city":"London","built":1886}
  //   }
  final feature = Feature(
    id: 'TB',
    geometry: Point(LonLat(-0.075406, 51.5055)),
    properties: {
      'title': 'Tower Bridge',
      'city': 'London',
      'built': 1886,
    },
  );
  print(feature.toText(format: GeoJSON.feature, decimals: 3));

  // -------

  // sample GeoJSON text representation (a feature collection with two features)
  const sample = '''
    {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": "ROG",
          "geometry": {
            "type": "Point",
            "coordinates": [-0.0014, 51.4778, 45.0]  
          },
          "properties": {
            "title": "Royal Observatory",
            "place": "Greenwich"
          }
        }, 
        {
          "type": "Feature",
          "id": "TB",
          "geometry": {
            "type": "Point",
            "coordinates": [-0.075406, 51.5055]  
          },
          "properties": {
            "title": "Tower Bridge",
            "built": 1886
          }
        } 
      ]
    }
  ''';

  // parse a FeatureCollection object using the decoder of the GeoJSON format
  final collection = FeatureCollection.parse(sample, format: GeoJSON.feature);

  // loop through features and print id, geometry and properties for each
  for (final feature in collection.features) {
    print('Feature with id: ${feature.id}');
    print('  geometry: ${feature.geometry}');
    print('  properties:');
    for (final key in feature.properties.keys) {
      print('    $key: ${feature.properties[key]}');
    }
  }
}

void _wkt() {
  // create a Point geometry
  final point = Point.build([10.123, 20.25, -30.95, -1.999], type: Coords.xyzm);

  // format it as WKT text that is printed:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  print(point.toText(format: WKT.geometry));

  // -------

  // It's possible to encode geometry data as WKT text also without creating
  // geometry objects first. However this requires accessing an encoder instance
  // from the WKT format, and then writing content to that encoder.

  // geometry text format encoder for WKT
  const format = WKT.geometry;
  final encoder = format.encoder();

  // prints:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  encoder.writer.point(
    [10.123, 20.25, -30.95, -1.999],
    type: Coords.xyzm,
  );
  print(encoder.toText());
}

void _wkbSample1() {
  // geometry binary format encoder for WKB
  const format = WKB.geometry;
  final encoder = format.encoder();

  // write geometries (here only point) to content writer of the encoder
  encoder.writer.point(
    [10.123, 20.25, -30.95, -1.999],
    type: Coords.xyzm,
  );

  // get encoded bytes (Uint8List) and Base64 encoded text (String)
  final wkbBytes = encoder.toBytes();
  final wkbBytesAsBase64 = encoder.toText();

  // prints (point encoded to WKB binary data, formatted as Base64 text):
  //    AAAAC7lAJD752yLQ5UA0QAAAAAAAwD7zMzMzMzO///vnbItDlg==
  print(wkbBytesAsBase64);

  // next decode this WKB binary data and use WKT text format encoder as target

  // geometry text format encoder for WKT
  final wktEncoder = WKT.geometry.encoder();

  // geometry binary format decoder for WKB
  // (with content writer of the WKT encoder set as a target for decoding)
  final decoder = WKB.geometry.decoder(wktEncoder.writer);

  // now decode those WKB bytes (Uint8List) created already at the start
  decoder.decodeBytes(wkbBytes);

  // finally print WKT text:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  print(wktEncoder.toText());
}

/// The previous sample ("_wkbSample1") using geometry model objects.
void _wkbSample2() {
  // create a Point object
  final point = Point(XYZM(10.123, 20.25, -30.95, -1.999));

  // get encoded bytes (Uint8List)
  final wkbBytes = point.toBytes(format: WKB.geometry);

  // at this point our WKB bytes could be sent to another system...

  // then create a Point object, but now decoding it from WKB bytes
  final pointDecoded = Point.decode(wkbBytes, format: WKB.geometry);

  // finally print WKT text:
  //    POINT ZM(10.123 20.25 -30.95 -1.999)
  print(pointDecoded.toText(format: WKT.geometry));

  // -------

  // or as a bonus of this solution it's as easy to print it as GeoJSON text too
  //    {"type":"Point","coordinates":[10.123,20.25,-30.95,-1.999]}
  print(pointDecoded.toText(format: GeoJSON.geometry));

  // great, but, we just forgot that GeoJSON should not contain m coordinates...
  //    {"type":"Point","coordinates":[10.123,20.25,-30.95]}
  print(
    pointDecoded.toText(
      format: GeoJSON.geometryFormat(conf: GeoJsonConf(ignoreMeasured: true)),
    ),
  );
}

void _temporalData() {
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

void _geospatialExtents() {
  // An extent with spatial (WGS 84 longitude-latitude) and temporal parts.
  GeoExtent.single(
    crs: 'EPSG:4326',
    bbox: GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0),
    interval: Interval.parse('../2020-10-31'),
  );

  // An extent with multiple spatial bounds and temporal interval segments.
  GeoExtent.multi(
    crs: 'EPSG:4326',
    boxes: [
      GeoBox(west: -20.0, south: 50.0, east: 20.0, north: 60.0),
      GeoBox(west: 40.0, south: 50.0, east: 60.0, north: 60.0),
    ],
    intervals: [
      Interval.parse('2020-10-01/2020-10-05'),
      Interval.parse('2020-10-27/2020-10-31'),
    ],
  );
}

void _wgs84ToWebMercator() {
  // Built-in coordinate projections (currently only between WGS 84 and
  // Web Mercator)

  // Geographic (WGS 84 longitude-latitude) to Projected (WGS 84 Web Mercator)
  final forward = WGS84.webMercator.forward;
  final projected = forward.project(
    const Geographic(lon: -0.0014, lat: 51.4778),
    to: Projected.create,
  );

  // Projected (WGS 84 Web Mercator) to Geographic (WGS 84 longitude-latitude)
  final inverse = WGS84.webMercator.inverse;
  final unprojected = inverse.project(
    projected,
    to: Geographic.create,
  );

  print('$unprojected <=> $projected');
}

/// "Web Mercator Quad" tile matrix set.
///
/// [OGC Two Dimensional Tile Matrix Set](https://docs.opengeospatial.org/is/17-083r2/17-083r2.html):
/// "Level 0 allows representing most of the world (limited to latitudes
/// between approximately ±85 degrees) in a single tile of 256x256 pixels
/// (Mercator projection cannot cover the whole world because mathematically
/// the poles are at infinity). The next level represents most of the world
/// in 2x2 tiles of 256x256 pixels and so on in powers of 2. Mercator
/// projection distorts the pixel size closer to the poles. The pixel sizes
/// provided here are only valid next to the equator."
///
/// Using "Web Mercator Quad" involves following coordinates:
/// * *position*: geographic coordinates (longitude, latitude)
/// * *world*: a position projected to the pixel space of the map at level 0
/// * *pixel*: pixel coordinates (x, y) in the pixel space of the map at zoom
/// * *tile*: tile coordinates (x, y) in the tile matrix at zoom
void _webMercatorQuad() {
  // "WebMercatorQuad" tile matrix set with 256 x 256 pixel tiles and with
  // "top-left" origin for the tile matrix and map pixel space
  const quad = WebMercatorQuad.epsg3857();

  // source position as geographic coordinates
  const position = Geographic(lon: -0.0014, lat: 51.4778);

  // get world, tile and pixel coordinates for a geographic position
  print(quad.positionToWorld(position)); // ~ x=127.999004 y=85.160341
  print(quad.positionToTile(position, zoom: 2)); // zoom=2 x=1 y=1
  print(quad.positionToPixel(position, zoom: 2)); // zoom=2 x=511 y=340
  print(quad.positionToPixel(position, zoom: 4)); // zoom=4 x=2047 y=1362

  // world coordinates can be instantiated as projected coordinates
  // x range: (0.0, 256.0) / y range: (0.0, 256.0)
  const world = Projected(x: 127.99900444444444, y: 85.16034098329446);

  // from world coordinates to tile and pixel coordinates
  print(quad.worldToTile(world, zoom: 2)); // zoom=2 x=1 y=1
  print(quad.worldToPixel(world, zoom: 2)); // zoom=2 x=511 y=340
  print(quad.worldToPixel(world, zoom: 4)); // zoom=4 x=2047 y=1362

  // tile and pixel coordinates with integer values can be defined too
  const tile = Scalable2i(zoom: 2, x: 1, y: 1);
  const pixel = Scalable2i(zoom: 2, x: 511, y: 340);

  // tile and pixel coordinates can be zoomed (scaled to other level of details)
  print(pixel.zoomIn()); // zoom=3 x=1022 y=680
  print(pixel.zoomOut()); // zoom=1 x=255 y=170

  // get tile bounds and pixel position (accucy lost) as geographic coordinates
  print(quad.tileToBounds(tile)); // west: -90 south: 0 east: 0 north: 66.51326
  print(quad.pixelToPosition(pixel)); // longitude: -0.17578 latitude: 51.50874

  // world coordinates returns geographic positions still accurately
  print(quad.worldToPosition(world)); // longitude: -0.00140 latitude: 51.47780

  // aligned points (world, pixel and position coordinates) inside tile or edges
  print(quad.tileToWorld(tile, align: Aligned.northWest));
  print(quad.tileToPixel(tile, align: Aligned.center));
  print(quad.tileToPosition(tile, align: Aligned.center));
  print(quad.tileToPosition(tile, align: Aligned.southEast));

  // get zoomed tile at the center of a source tile
  final centerOfTile2 = quad.tileToWorld(tile, align: Aligned.center);
  final tile7 = quad.worldToTile(centerOfTile2, zoom: 7);
  print('tile at zoom 2: $tile => center of tile: $centerOfTile2 '
      '=> tile at zoom 7: $tile7');

  // a quad key is a string identifier for tiles
  print(quad.tileToQuadKey(tile)); // "03"
  print(quad.quadKeyToTile('03')); // zoom=2 x=1 y=1
  print(quad.quadKeyToTile('0321')); // zoom=4 x=5 y=6

  // tile size and map bounds can be checked dynamically
  print(quad.tileSize); // 256
  print(quad.mapBounds()); // ~ west: -180 south: -85.05 east: 180 north: 85.05

  // matrix width and height tells number of tiles in a given zoom level
  print('${quad.matrixWidth(2)} x ${quad.matrixHeight(2)}'); // 4 x 4
  print('${quad.matrixWidth(10)} x ${quad.matrixHeight(10)}'); // 1024 x 1024

  // map width and height tells number of pixels in a given zoom level
  print('${quad.mapWidth(2)} x ${quad.mapHeight(2)}'); // 1024 x 1024
  print('${quad.mapWidth(10)} x ${quad.mapHeight(10)}'); // 262144 x 262144

  // ground resolutions and scale denominator for zoom level 10 at the Equator
  print(quad.tileGroundResolution(10)); // ~ 39135.76 (meters)
  print(quad.pixelGroundResolution(10)); // ~ 152.87 (meters)
  print(quad.scaleDenominator(10)); // ~ 545978.77

  // ground resolutions and scale denominator for zoom level 10 at lat 51.4778
  print(quad.pixelGroundResolutionAt(latitude: 51.4778, zoom: 10)); // ~ 95.21
  print(quad.scaleDenominatorAt(latitude: 51.4778, zoom: 10)); // ~ 340045.31
}

/// "Global Geodetic Quad" tile matrix set ("World CRS84 Quad" for WGS 84).
///
/// Tiles are defined in the Equirectangular Plate Carrée projection in the
/// CRS84 coordinate reference system (longitude, latitude) for the whole
/// world. At the zoom level 0 the world is covered by two tiles (tile matrix
/// width is 2 and matrix height is 1). The western tile (x=0, y=0) is for the
/// negative longitudes and the eastern tile (x=1, y=0) for the positive
/// longitudes.
///
/// Using "Global Geodetic Quad" involves following coordinates:
/// * *position*: geographic coordinates (longitude, latitude)
/// * *world*: a position scaled to the pixel space of the map at level 0
/// * *pixel*: pixel coordinates (x, y) in the pixel space of the map at zoom
/// * *tile*: tile coordinates (x, y) in the tile matrix at zoom
void _globalGeodeticQuad() {
  // "World CRS 84" tile matrix set with 256 x 256 pixel tiles and with
  // "top-left" origin for the tile matrix and map pixel space
  const quad = GlobalGeodeticQuad.worldCrs84();

  // source position as geographic coordinates
  const position = Geographic(lon: -0.0014, lat: 51.4778);

  // get world, tile and pixel coordinates for a geographic position
  print(quad.positionToWorld(position)); // ~ x=255.998009 y=54.787129
  print(quad.positionToTile(position, zoom: 2)); // zoom=2 x=3 y=0
  print(quad.positionToPixel(position, zoom: 2)); // zoom=2 x=1023 y=219
  print(quad.positionToPixel(position, zoom: 4)); // zoom=4 x=4095 y=876

  // world coordinates can be instantiated as projected coordinates
  // x range: (0.0, 512.0) / y range: (0.0, 256.0)
  const world = Projected(x: 255.99800888888888, y: 54.78712888888889);

  // from world coordinates to tile and pixel coordinates
  print(quad.worldToTile(world, zoom: 2)); // zoom=2 x=3 y=0
  print(quad.worldToPixel(world, zoom: 2)); // zoom=2 x=1023 y=219
  print(quad.worldToPixel(world, zoom: 4)); //  zoom=4 x=4095 y=876

  // tile and pixel coordinates with integer values can be defined too
  const tile = Scalable2i(zoom: 2, x: 3, y: 0);
  const pixel = Scalable2i(zoom: 2, x: 1023, y: 219);

  // get tile bounds and pixel position (accucy lost) as geographic coordinates
  print(quad.tileToBounds(tile)); // west: -45 south: 45 east: 0 north: 90
  print(quad.pixelToPosition(pixel)); // longitude: -0.08789 latitude: 51.41602

  // world coordinates returns geographic positions still accurately
  print(quad.worldToPosition(world)); // longitude: -0.00140 latitude: 51.4778

  // tile size and map bounds can be checked dynamically
  print(quad.tileSize); // 256
  print(quad.mapBounds()); // west: -180 south: -90 east: 180 north: 90

  // matrix width and height tells number of tiles in a given zoom level
  print('${quad.matrixWidth(2)} x ${quad.matrixHeight(2)}'); // 8 x 4
  print('${quad.matrixWidth(10)} x ${quad.matrixHeight(10)}'); // 2048 x 1024

  // map width and height tells number of pixels in a given zoom level
  print('${quad.mapWidth(2)} x ${quad.mapHeight(2)}'); // 2048 x 1024
  print('${quad.mapWidth(10)} x ${quad.mapHeight(10)}'); // 524288 x 262144

  // arc resolutions and scale denominator for zoom level 10 at the Equator
  print(quad.tileArcResolution(10)); // ~ 0.175781 (° degrees)
  print(quad.pixelArcResolution(10)); // ~ 0.000686646 (° degrees)
  print(quad.scaleDenominator(10)); // ~ 272989.39
}
