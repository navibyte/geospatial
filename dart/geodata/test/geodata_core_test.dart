// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_types_on_closure_parameters
// ignore_for_file: prefer_const_constructors,require_trailing_commas
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:equatable/equatable.dart';

import 'package:geodata/core.dart';

import 'package:test/test.dart';

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  group('Geodata "core/data" tests', () {
    setUp(() {
      // NOP
    });

    test('GeospatialQuery', () {
      final query = GeospatialQuery(crs: 'EPSG:4326', extra: {
        'string': 'this is str',
        'int': 123,
        'double': 93.4245,
        'bool': false,
        'null': null,
      });
      expect(query.crs, 'EPSG:4326');
      expect(query.extraParams, <String, String>{
        'string': 'this is str',
        'int': '123',
        'double': '93.4245',
        'bool': 'false',
        'null': 'null',
      });
      expect(Uri(path: 'a/b', queryParameters: query.extraParams).toString(),
          'a/b?string=this+is+str&int=123&double=93.4245&bool=false&null=null');
    });
  });
}
