// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_literals_to_create_immutables
// ignore_for_file: avoid_redundant_argument_values, no_adjacent_strings_in_list

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector.dart';
import 'package:geobase/vector_data.dart';

import 'package:test/test.dart';

import 'vector_data_geometry_test.dart';

void main() {
  group('Feature class', () {
    test('Feature.new', () {
      // a feature with an id and a point geometry (2D coordinates)
      testFeatureP(
        Feature(
          id: '1',
          geometry: Point([10.0, 20.0].xy),
        ),
      );

      // a feature with properties and a line string geometry (3D coordinates)
      testFeatureLS(
        Feature(
          geometry: LineString(
            // three (x, y, z) positions
            [10.0, 20.0, 30.0, 12.5, 22.5, 32.5, 15.0, 25.0, 35.0]
                .positions(Coords.xyz),
          ),
          // properties for a feature containing JSON Object like data
          properties: {
            'textProp': 'this is property value',
            'intProp': 10,
            'doubleProp': 29.5,
            'arrayProp': ['foo', 'bar'],
          },
        ),
      );
    });

    test('Feature.build', () {
      // a feature with an id and a point geometry (2D coordinates)
      testFeatureP(
        Feature.build(
          id: '1',
          geometry: (geom) => geom.point([10.0, 20.0].xy),
        ),
      );

      // a feature with properties and a line string geometry (3D coordinates)
      testFeatureLS(
        Feature.build(
          geometry: (geom) => geom.lineString(
            // three (x, y, z) positions
            [10.0, 20.0, 30.0, 12.5, 22.5, 32.5, 15.0, 25.0, 35.0]
                .positions(Coords.xyz),
          ),
          // properties for a feature containing JSON Object like data
          properties: {
            'textProp': 'this is property value',
            'intProp': 10,
            'doubleProp': 29.5,
            'arrayProp': ['foo', 'bar'],
          },
        ),
      );
    });

    test('Feature.parse', () {
      // a feature with an id and a point geometry (2D coordinates)
      testFeatureP(
        Feature.parse(
          format: GeoJSON.feature,
          '''
          {
            "type": "Feature",
            "id": "1",
            "geometry": {
              "type": "Point",
              "coordinates": [10.0, 20.0]
            }
          }
          ''',
        ),
      );

      // a feature with properties and a line string geometry (3D coordinates)
      testFeatureLS(
        Feature.parse(
          format: GeoJSON.feature,
          '''
          {
            "type": "Feature",
            "geometry": {
              "type": "LineString", 
              "coordinates": [
                [10.0, 20.0, 30.0],
                [12.5, 22.5, 32.5],
                [15.0, 25.0, 35.0]
              ]
            },
            "properties": {
              "textProp": "this is property value",
              "intProp": 10,
              "doubleProp": 29.5,
              "arrayProp": ["foo", "bar"]
            }
          }
          ''',
        ),
      );
    });

    test('Feature.fromData', () {
      // a feature with an id and a point geometry (2D coordinates)
      testFeatureP(
        Feature.fromData(
          format: GeoJSON.feature,
          {
            'type': 'Feature',
            'id': '1',
            'geometry': {
              'type': 'Point',
              'coordinates': [10.0, 20.0]
            }
          },
        ),
      );

      // a feature with properties and a line string geometry (3D coordinates)
      testFeatureLS(
        Feature.fromData(
          format: GeoJSON.feature,
          {
            'type': 'Feature',
            'geometry': {
              'type': 'LineString',
              'coordinates': [
                [10.0, 20.0, 30.0],
                [12.5, 22.5, 32.5],
                [15.0, 25.0, 35.0]
              ]
            },
            'properties': {
              'textProp': 'this is property value',
              'intProp': 10,
              'doubleProp': 29.5,
              'arrayProp': ['foo', 'bar']
            }
          },
        ),
      );
    });
  });

  group('FeatureCollection class', () {
    test('FeatureCollection.new', () {
      testFeatureCollection(
        // a feature collection with two features
        FeatureCollection([
          // a feature with an id and a point geometry (2D coordinates)
          Feature(
            id: '1',
            geometry: Point([10.0, 20.0].xy),
          ),

          // a feature with properties and a line string geometry (3D)
          Feature(
            geometry: LineString(
              // three (x, y, z) positions
              [10.0, 20.0, 30.0, 12.5, 22.5, 32.5, 15.0, 25.0, 35.0]
                  .positions(Coords.xyz),
            ),
            // properties for a feature containing JSON Object like data
            properties: {
              'textProp': 'this is property value',
              'intProp': 10,
              'doubleProp': 29.5,
              'arrayProp': ['foo', 'bar'],
            },
          ),
        ]),
      );
    });

    test('FeatureCollection.build', () {
      testFeatureCollection(
        // a feature collection with two features
        FeatureCollection.build(
          count: 2,
          (feat) => feat
            // a feature with an id and a point geometry (2D coordinates)
            ..feature(
              id: '1',
              geometry: (geom) => geom.point([10.0, 20.0].xy),
            )

            // a feature with properties and a line string geometry (3D)
            ..feature(
              geometry: (geom) => geom.lineString(
                // three (x, y, z) positions
                [10.0, 20.0, 30.0, 12.5, 22.5, 32.5, 15.0, 25.0, 35.0]
                    .positions(Coords.xyz),
              ),
              // properties for a feature containing JSON Object like data
              properties: {
                'textProp': 'this is property value',
                'intProp': 10,
                'doubleProp': 29.5,
                'arrayProp': ['foo', 'bar'],
              },
            ),
        ),
      );
    });

    test('FeatureCollection.parse', () {
      testFeatureCollection(
        // a feature collection with two features
        FeatureCollection.parse(
          format: GeoJSON.feature,
          '''
          {
            "type": "FeatureCollection",
            "features": [
              {
                "type": "Feature",
                "id": "1",
                "geometry": {
                  "type": "Point",
                  "coordinates": [10.0, 20.0]
                }
              },
              {
                "type": "Feature",
                "geometry": {
                  "type": "LineString",
                  "coordinates": [
                    [10.0, 20.0, 30.0],
                    [12.5, 22.5, 32.5],
                    [15.0, 25.0, 35.0]
                  ]
                },
                "properties": {
                  "textProp": "this is property value",
                  "intProp": 10,
                  "doubleProp": 29.5,
                  "arrayProp": ["foo", "bar"]
                }
              }
            ]
          }
          ''',
        ),
      );
    });

    test('FeatureCollection.fromData', () {
      testFeatureCollection(
        // a feature collection with two features
        FeatureCollection.fromData(
          format: GeoJSON.feature,
          {
            'type': 'FeatureCollection',
            'features': [
              // a feature with an id and a point geometry (2D coordinates)
              {
                'type': 'Feature',
                'id': '1',
                'geometry': {
                  'type': 'Point',
                  'coordinates': [10.0, 20.0]
                }
              },
              // a feature with properties and a line string geometry (3D)
              {
                'type': 'Feature',
                'geometry': {
                  'type': 'LineString',
                  'coordinates': [
                    [10.0, 20.0, 30.0],
                    [12.5, 22.5, 32.5],
                    [15.0, 25.0, 35.0]
                  ]
                },
                'properties': {
                  'textProp': 'this is property value',
                  'intProp': 10,
                  'doubleProp': 29.5,
                  'arrayProp': ['foo', 'bar']
                }
              }
            ]
          },
        ),
      );
    });
  });
}

/// Tests `Feature` object with `Point` geometry.
void testFeatureP(Feature feature) {
  testPoint(feature.geometry! as Point);
  expect(feature.id, '1');
  expect(feature.properties, const <String, dynamic>{});
}

/// Tests `Feature` object with `LineString` geometry.
void testFeatureLS(Feature feature) {
  testLineString(feature.geometry! as LineString);
  expect(feature.id, isNull);
  expect(feature.properties, {
    'textProp': 'this is property value',
    'intProp': 10,
    'doubleProp': 29.5,
    'arrayProp': ['foo', 'bar'],
  });
}

/// Tests `FeatureCollection` object.
void testFeatureCollection(FeatureCollection collection) {
  expect(collection.features.length, 2);
  testFeatureP(collection.features[0]);
  testFeatureLS(collection.features[1]);
}
