// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars

const geoJsonGeometries = [
  '{"type":"Point","coordinates":[0.0,0.0,0.0]}',
  '{"type":"Point","coordinates":[1.5,2.5]}',
  '{"type":"Point","coordinates":[1.5,2.5,3.5]}',
  '{"type":"Point","coordinates":[1.5,2.5,3.5,4.5]}',
  '{"type":"LineString","coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]}',
  '{"type":"LineString","coordinates":[[-1.1,-1.1,-1.1],[2.1,-2.5,2.3],[3.5,-3.49,11.3]]}',
  '{"type":"LineString","coordinates":[[-1.1,-1.1,-1.1,-1.1],[2.1,-2.5,2.3,0.1],[3.5,-3.49,11.3,0.23]]}',
  '{"type":"LineString","bbox":[-1.1,-3.49,3.5,-1.1],"coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]}',
  '{"type":"Polygon","coordinates":[[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]]]}',
  '{"type":"Polygon","coordinates":[[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]],[[11.1,11.1],[6.0,9.9],[13.0,4.9],[11.1,11.1]]]}',
  '{"type":"Polygon","coordinates":[[[10.1,10.1,10.1],[5.0,9.0,13.0],[12.0,4.0,2.0],[10.1,10.1,10.1]]]}',
  '{"type":"Polygon","coordinates":[[[10.1,10.1,10.1,3.1],[5.0,9.0,13.0,3.2],[12.0,4.0,2.0,3.3],[10.1,10.1,10.1,3.4]]]}',
  '{"type":"MultiPoint","coordinates":[]}',
  '{"type":"MultiPoint","coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]}',
  '{"type":"MultiPoint","coordinates":[[-1.1,-1.1,-1.1],[2.1,-2.5,2.3],[3.5,-3.49,11.3]]}',
  '{"type":"MultiPoint","coordinates":[[-1.1,-1.1,-1.1,-1.1],[2.1,-2.5,2.3,0.1],[3.5,-3.49,11.3,0.23]]}',
  '{"type":"MultiLineString","coordinates":[]}',
  '{"type":"MultiLineString","coordinates":[[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]],[[11.1,11.1],[6.0,9.9],[13.0,4.9],[11.1,11.1]]]}',
  '{"type":"MultiPolygon","coordinates":[]}',
  '{"type":"MultiPolygon","coordinates":[[[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]],[[11.1,11.1],[6.0,9.9],[13.0,4.9],[11.1,11.1]]]]}',
  '{"type":"GeometryCollection","geometries":[]}',
  '{"type":"GeometryCollection","geometries":[{"type":"Point","coordinates":[10.123,20.25,-30.95]},{"type":"LineString","coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]},{"type":"Polygon","coordinates":[[[10.1,10.1],[5.0,9.0],[12.0,4.0],[10.1,10.1]]]}]}',
  '{"type":"GeometryCollection","geometries":[{"type":"Point","coordinates":[10.123,20.25,-30.95]},{"type":"LineString","coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]},{"type":"Polygon","coordinates":[[[10.1,10.1,10.1,3.1],[5.0,9.0,13.0,3.2],[12.0,4.0,2.0,3.3],[10.1,10.1,10.1,3.4]]]}]}',
];

const geoJsonFeatures = [
  '{"type":"Feature","properties":{}}',
  '{"type":"Feature","properties":{}}',
  '{"type":"Feature","id":123,"properties":{"sub":{"param1":1,"param2":2}}}',
  '{"type":"Feature","id":"fid-1","geometry":{"type":"Point","coordinates":[10.123,20.25]},"properties":{"foo":100,"bar":"this is property value","baz":true}}',
];

const geoJsonFeatureCollections = [
  '{"type":"FeatureCollection","features":[]}',
  '{"type":"FeatureCollection","features":[{"type":"Feature","id":"fid-1","geometry":{"type":"Point","coordinates":[10.123,20.25]},"properties":{"foo":100,"bar":"this is property value"}},{"type":"Feature","geometry":{"type":"LineString","coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]},"properties":{}}]}',
  '{"type":"FeatureCollection","bbox":[-1.1,-3.49,10.123,20.25],"features":[{"type":"Feature","id":"fid-1","geometry":{"type":"Point","coordinates":[10.123,20.25]},"properties":{"foo":100,"bar":"this is property value"}},{"type":"Feature","geometry":{"type":"LineString","bbox":[-1.1,-3.49,3.5,-1.1],"coordinates":[[-1.1,-1.1],[2.1,-2.5],[3.5,-3.49]]},"properties":{}}]}',
];
