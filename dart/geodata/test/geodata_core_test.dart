// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_types_on_closure_parameters
// ignore_for_file: prefer_const_constructors,require_trailing_commas
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:equatable/equatable.dart';

import 'package:geobase/coordinates.dart';
import 'package:geobase/meta.dart';
import 'package:geodata/core.dart';
import 'package:geodata/src/utils/resolve_api_call.dart';

import 'package:test/test.dart';

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  group('Geodata "core/data" tests', () {
    setUp(() {
      // NOP
    });

    test('GeospatialQuery', () {
      final query = GeospatialQuery(crs: CoordRefSys.EPSG_4326, extra: {
        'string': 'this is str',
        'int': 123,
        'double': 93.4245,
        'bool': false,
        'null': null,
        'instant': Instant.parse('2022-01-15 19:01:22'),
        'interval': Interval.parse('../2022-01-15 19:01:22'),
        'bounds': GeoBox(
          west: -10.1,
          south: -20.2,
          minElev: -400.0,
          east: 10.1,
          north: 20.2,
          maxElev: 400.0,
        ),
      });
      expect(query.crs?.epsg, 'EPSG:4326');
      expect(query.extraParams, <String, String>{
        'string': 'this is str',
        'int': '123',
        'double': '93.4245',
        'bool': 'false',
        'null': 'null',
        'instant': '2022-01-15T19:01:22.000',
        'interval': '../2022-01-15T19:01:22.000',
        'bounds': '-10.1,-20.2,-400.0,10.1,20.2,400.0',
      });
      expect(
          Uri(path: 'a/b', queryParameters: query.extraParams).toString(),
          'a/b?string=this+is+str&int=123&double=93.4245&bool=false&null=null&'
          'instant=2022-01-15T19%3A01%3A22.000&'
          'interval=..%2F2022-01-15T19%3A01%3A22.000&'
          'bounds=-10.1%2C-20.2%2C-400.0%2C10.1%2C20.2%2C400.0');
    });
  });

  group('Uri test', () {
    final endpoint1 = Uri.parse('https://example.org/myapp/');
    final endpoint2 = Uri.parse('https://example.org/myapp');
    final endpoint3 = Uri.parse('https://example.org/myapp/part/');
    final endpoint4 = Uri.parse('https://example.org/myapp/part');

    test('Uri.resolve', () {
      expect(
        endpoint1.resolve('sub'),
        Uri.parse('https://example.org/myapp/sub'),
      );
      expect(
        endpoint1.resolve('/sub'),
        Uri.parse('https://example.org/sub'),
      );

      expect(
        endpoint2.resolve('sub'),
        Uri.parse('https://example.org/sub'),
      );
      expect(
        endpoint2.resolve('/sub'),
        Uri.parse('https://example.org/sub'),
      );

      expect(
        endpoint3.resolve('sub'),
        Uri.parse('https://example.org/myapp/part/sub'),
      );
      expect(
        endpoint3.resolve('/sub'),
        Uri.parse('https://example.org/sub'),
      );

      expect(
        endpoint4.resolve('sub'),
        Uri.parse('https://example.org/myapp/sub'),
      );
      expect(
        endpoint4.resolve('/sub'),
        Uri.parse('https://example.org/sub'),
      );
    });

    test('resolveAPICall', () {
      expect(
        resolveSubResource(endpoint1, 'sub'),
        Uri.parse('https://example.org/myapp/sub'),
      );
      expect(
        resolveSubResource(endpoint1, '/sub'),
        Uri.parse('https://example.org/sub'),
      );

      expect(
        resolveSubResource(endpoint2, 'sub'),
        Uri.parse('https://example.org/myapp/sub'),
      );
      expect(
        resolveSubResource(endpoint2, '/sub'),
        Uri.parse('https://example.org/sub'),
      );

      expect(
        resolveSubResource(endpoint3, 'sub'),
        Uri.parse('https://example.org/myapp/part/sub'),
      );
      expect(
        resolveSubResource(endpoint3, '/sub'),
        Uri.parse('https://example.org/sub'),
      );

      expect(
        resolveSubResource(endpoint4, 'sub'),
        Uri.parse('https://example.org/myapp/part/sub'),
      );
      expect(
        resolveSubResource(endpoint4, '/sub'),
        Uri.parse('https://example.org/sub'),
      );
    });
  });
}
