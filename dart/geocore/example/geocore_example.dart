// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:equatable/equatable.dart';

import 'package:geocore/geocore.dart';

/*
To test run this from command line: 

dart example/geocore_example.dart
*/

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  // call simple demos
  _parseGeoJSON();
  _basicStructures();
}

void _parseGeoJSON() {
  print('Parse GeoJSON sample data.');

  // sample GeoJSON data
  const sample = '''
    {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": "greenwich",
          "geometry": {
            "type": "Point",
            "coordinates": [-0.0014, 51.4778, 45.0]  
          },
          "properties": {
            "title": "Royal Observatory",
            "place": "Greenwich",
            "city": "London"
          }
        }  
      ]
    }
  ''';

  // parse FeatureCollection using the default GeoJSON factory
  final fc = geoJSON.featureCollection(sample);

  // loop through features and print id, geometry and properties for each
  fc.features.forEach((f) {
    print('Feature with id: ${f.id}');
    print('  geometry: ${f.geometry}');
    print('  properties:');
    f.properties.forEach((key, value) => print('    $key: $value'));
  });
}

void _basicStructures() {
  print('');
  print('Create some basic data structures.');

  // Geospatial feature
  print(Feature.of(
    id: 'greenwich',
    geometry: GeoPoint.from([-0.0014, 51.4778, 45.0]),
    properties: {
      'title': 'Royal Observatory',
      'place': 'Greenwich',
      'city': 'London',
    },
  ));

  // Geographical points (lon-lat, lon-lat-m, lon-lat-elev, lon-lat-elev-m)
  print(GeoPoint2.lonLat(-0.0014, 51.4778));
  print(GeoPoint2m.lonLatM(-0.0014, 51.4778, 123.0));
  print(GeoPoint3.lonLatElev(-0.0014, 51.4778, 45.0));
  print(GeoPoint3m.lonLatElevM(-0.0014, 51.4778, 45.0, 123.0));

  // Geographical points (lat-lon, lat-lon-m, lat-lon-elev, lat-lon-elev-m)
  print(GeoPoint2.latLon(51.4778, -0.0014));
  print(GeoPoint2m.latLonM(51.4778, -0.0014, 123.0));
  print(GeoPoint3.latLonElev(51.4778, -0.0014, 45.0));
  print(GeoPoint3m.latLonElevM(51.4778, -0.0014, 45.0, 123.0));

  // Geographical camera
  print(GeoCamera.target(
    GeoPoint3.from([51.4778, -0.0014, 45.0]),
    zoom: 10.0,
    bearing: 60.0,
    tilt: 10.0,
  ));

  // Geographical bounds
  print(GeoBounds.bboxLonLat(-180.0, -90.0, 180.0, 90.0));
  print(GeoBounds.bboxLonLatElev(-180.0, -90.0, 50.0, 180.0, 90.0, 100.0));
  print(GeoBounds.bboxLatLon(-90.0, -180.0, 90.0, 180.0));

  // Cartesian points (XY, XYM, XYZ and XYZM) using doubles
  print(Point2.xy(708221.0, 5707225.0));
  print(Point2m.xym(708221.0, 5707225.0, 123.0));
  print(Point3.xyz(708221.0, 5707225.0, 45.0));
  print(Point3m.xyzm(708221.0, 5707225.0, 45.0, 123.0));

  // Cartesian points (XY, XYZ) using integers
  print(Point2i.xy(708221, 5707225));
  print(Point3i.xyz(708221, 5707225, 45));

  // Temporal intervals (open, open-started, open-ended, closed)
  print(Interval.open());
  print(Interval.openStart(DateTime.utc(2020, 10, 31)));
  print(Interval.openEnd(DateTime.utc(2020, 10, 01)));
  print(
      Interval.closed(DateTime.utc(2020, 10, 01), DateTime.utc(2020, 10, 31)));

  // Temporal instant
  print(Instant.parse('2020-10-31'));

  // Coordinate reference system (identifiers)
  print(CRS84);
  print(CRS84h);
  print(CRS.id('urn:ogc:def:crs:EPSG::4326'));

  // Extent
  print(Extent.single(
    crs: CRS84,
    bounds: GeoBounds.fromJson([-180.0, -90.0, 180.0, 90.0]),
    interval: Interval.fromJson(['..', '2020-10-31']),
  ));

  // Link
  print(Link(
    href: 'http://example.com',
    rel: 'alternate',
    type: 'application/json',
    title: 'Other content',
  ));
}
