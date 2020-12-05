// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:equatable/equatable.dart';

import 'package:geocore/geocore.dart';

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  // Cartesian points (XY, XYM, XYZ and XYZM) using doubles
  print(Point2.xy(291692.0, 5707473.0));
  print(Point2m.xym(291692.0, 5707473.0, 123.0));
  print(Point3.xyz(291692.0, 5707473.0, 11.0));
  print(Point3m.xyzm(291692.0, 5707473.0, 11.0, 123.0));

  // Cartesian points (XY, XYZ) using integers
  print(Point2i.xy(291692, 5707473));
  print(Point3i.xyz(291692, 5707473, 11));

  // Geographical points (lon-lat, lon-lat-elev) using doubles
  print(GeoPoint2.lonLat(0.0, 51.48));
  print(GeoPoint3.lonLatElev(0.0, 51.48, 11));

  // Geographical points (lat-lon, lat-lon-elev) using doubles
  print(GeoPoint2.latLon(51.48, 0.0));
  print(GeoPoint3.latLonElev(51.48, 0.0, 11));

  // Geographical camera
  print(GeoCamera.target(
    GeoPoint3.from([51.48, 0.0, 11]),
    zoom: 10.0,
    bearing: 45.0,
    tilt: 10.0,
  ));

  // Geographical bounds
  print(GeoBounds.bboxLonLat(-180.0, -90.0, 180.0, 90.0));
  print(GeoBounds.bboxLonLatElev(-180.0, -90.0, 50.0, 180.0, 90.0, 100.0));
  print(GeoBounds.bboxLatLon(-90.0, -180.0, 90.0, 180.0));

  // Temporal intervals (open, open-started, open-ended, closed)
  print(Interval.open());
  print(Interval.openStart(DateTime.utc(2020, 10, 31)));
  print(Interval.openEnd(DateTime.utc(2020, 10, 01)));
  print(
      Interval.closed(DateTime.utc(2020, 10, 01), DateTime.utc(2020, 10, 31)));

  // Temporal instant
  print(Instant.from('2020-10-31'));

  // Coordinate reference systems
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

  // Geospatial feature
  print(Feature.of(
    id: 'greenwich',
    geometry: GeoPoint3.lonLatElev(0.0, 51.48, 11),
    properties: {
      'title': 'Greenwich',
      'city': 'London',
    },
  ));
}
