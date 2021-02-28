// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:test/test.dart';

void main() {
  group('Datatools basic structures', () {
    setUp(() {
      // NOP
    });

    test('Testing how resolveUri of the Uri class works', () {
      final baseUri = Uri.parse('https://example.org/sub/');
      expect(baseUri.resolveUri(Uri(path: 'some/path')),
          Uri.parse('https://example.org/sub/some/path'));
      expect(
          baseUri.resolveUri(Uri(
              path: '/at_root', queryParameters: {'bbox': '7,50.6,7.2,50.8'})),
          Uri.parse('https://example.org/at_root?bbox=7%2C50.6%2C7.2%2C50.8'));
      expect(
          baseUri.resolveUri(Uri(
              path: 'some/path', queryParameters: {'foo': 'bar', 'one': '1'})),
          Uri.parse('https://example.org/sub/some/path?foo=bar&one=1'));
      expect(
          baseUri.resolveUri(Uri(path: 'some/path', queryParameters: {
            'foo': 'bar',
            'one': '1',
            'multi': ['a', 'b']
          })),
          Uri.parse(
              'https://example.org/sub/some/path?foo=bar&one=1&multi=a&multi=b'));
    });
  });
}
