// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars

const wktGeometries = [
  // points
  'POINT(10.1 20.2)',
  'POINT Z(10.1 20.2 30.3)',
  'POINT M(10.1 20.2 30.3)',
  'POINT ZM(10.1 20.2 30.3 40.4)',

  // line strings
  'LINESTRING(10.1 10.1,20.2 20.2,30.3 30.3)',

  // polygons
  'POLYGON((10.1 10.1,20.2 10.1,20.2 20.2,10.1 20.2,10.1 10.1))',
  'POLYGON((35 10,45 45,15 40,10 20,35 10))',

  // multi points
  'MULTIPOINT(10.1 10.1,20.2 20.2,30.3 30.3)',

  // multi linestrings
  'MULTILINESTRING((35 10,45 45,15 40,10 20,35 10))',

  // multi polygons
  'MULTIPOLYGON(((35 10,45 45,15 40,10 20,35 10)))',

  // geometry collections
  'GEOMETRYCOLLECTION(POINT(10.1 20.2),POINT M(10.1 20.2 30.3),LINESTRING(10.1 10.1,20.2 20.2,30.3 30.3))',

  // empty geometries
  'POINT EMPTY',
  'LINESTRING EMPTY',
  //'POLYGON EMPTY',
  'MULTIPOINT EMPTY',
  'MULTILINESTRING EMPTY',
  'MULTIPOLYGON EMPTY',
  'GEOMETRYCOLLECTION EMPTY',
];
