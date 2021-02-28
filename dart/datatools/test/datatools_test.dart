// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:http/http.dart' as http;

import 'package:test/test.dart';

import 'package:datatools/fetch_http.dart';

import 'test_utils.dart';
import 'test_snippets.dart';

void main() async {
  final endpoint = Uri.parse('https://jsonplaceholder.typicode.com/');
  final refPosts2 = Uri(path: 'posts/2');

  group('HTTP fetch functions:', () {
    final urlPosts2 = endpoint.resolveUri(refPosts2);

    test('Read using fetch functions', () async {
      expect(await fetchText(urlPosts2), post2);
      expect(b2s(await fetchBytes(urlPosts2)), post2);
      expect((await fetchJson(urlPosts2))['title'], post2Title);
      expect(bd2s(await (await fetch(urlPosts2)).byteData(40, 52)), post2Title);
      expect(await (await fetchStream(urlPosts2)).text, post2);
    });
  });

  group('HTTP fetcher:', () {
    final refPostsNotFound = Uri(path: 'posts/xyz');

    // test with persistent http.Client
    late http.Client client;
    late HttpFetcher fetcher;

    setUp(() {
      client = http.Client();
      fetcher = HttpFetcher.client(client, endpoints: [endpoint]);
    });

    tearDown(() {
      client.close();
    });

    test('Read directly from client', () async {
      expect(await fetcher.fetchText(refPosts2), post2);
      expect(b2s(await fetcher.fetchBytes(refPosts2)), post2);
      expect((await fetcher.fetchJson(refPosts2))['title'], post2Title);
    });

    test('Fetch a body, then meta and head information', () async {
      final content = await fetcher.fetch(refPosts2);
      expect(content.reference, refPosts2);
      expect(content.contentLength, 278);
      expect(content.hasType('application', 'json'), true);
      expect(content.encoding.name, 'utf-8');
    });

    test('Fetch a body, then read text, bytes and json from same body instance',
        () async {
      final content = await fetcher.fetch(refPosts2);
      expect(await content.text, post2);
      expect(b2s(await content.bytes), post2);
      expect(bd2s(await content.byteData()), post2);
      expect(bd2s(await content.byteData(40, 52)), post2Title);
      expect(bd2s(await content.byteData(0, 40)), post2FromStartToTitle);
      expect(bd2s(await content.byteData(40)), post2FromTitleToEnd);
      expect((await content.decodeJson())['title'], post2Title);
    });

    test('Fetch a stream, then read text from strem', () async {
      final content = await fetcher.fetchStream(refPosts2);
      expect(await content.text, post2);
      // if same stream used second time, an exception should occur
      expect(() async => b2s(await content.bytes), throwsException);
    });

    test('Fetch a stream, then read bytes from strem', () async {
      final content = await fetcher.fetchStream(refPosts2);
      expect(b2s(await content.bytes), post2);
    });

    test('Fetch a stream, then read byte data range from strem', () async {
      final content = await fetcher.fetchStream(refPosts2);
      expect(bd2s(await content.byteData(40, 52)), post2Title);
    });

    test('Fetch a stream, then read byte blocks from stream', () async {
      final content = await fetcher.fetchStream(refPosts2);
      var i = 0;
      await for (var bytes in await content.stream) {
        //print(bytes);
        for (var b in bytes) {
          expect(b, post2AsBytes[i++]);
        }
      }
    });

    test('Fetch a non-existent resource (not found should happen)', () async {
      try {
        await fetcher.fetchText(refPostsNotFound);
      } on OriginException catch (e) {
        // common failure test
        expect(e.isNotFound, true);
        // also http specific test
        expect(e.statusCode, 404);
      }
    });
  });
}
