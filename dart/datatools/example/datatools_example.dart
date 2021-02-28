// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:equatable/equatable.dart';

import 'package:datatools/fetch_api.dart';
import 'package:datatools/fetch_http.dart';
import 'package:datatools/fetch_file.dart';
import 'package:datatools/meta_link.dart';

/*
To test run this from command line: 

dart example/datatools_example.dart
*/

void main() async {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  // call simple demos
  await _httpFetcher();
  await _httpFetcherWithClient();
  await _fileFetcher();
  _metadataStructures();
}

Future<void> _httpFetcher() async {
  print('');
  print('Using HTTP fetcher.');

  // create a simple fetcher with an endpoint and headers
  final fetcher = HttpFetcher.simple(
          endpoints: [Uri.parse('https://jsonplaceholder.typicode.com/')])
      .headers({'user-agent': 'datatools-sample'});

  // fetch by a relative path, get content as JSON and handle errors
  try {
    final json = await fetcher.fetchJson(Uri(path: 'posts/1'));
    print('* Title for post 1 : ' + json['title']);
  } on OriginException catch (e) {
    print('Origin exception: ' +
        (e.isNotFound ? 'not found' : 'status code ${e.statusCode}'));
  } catch (e) {
    print('Other exception: $e');
  }

  // fetch content, and then decode it as JSON and use as bytes or text
  try {
    // fetch content
    final content = await fetcher.fetch(Uri(path: 'posts/2'));

    // decode and use JSON data
    final json = await content.decodeJson();
    print('* Title for post 2 : ' + json['title']);

    // read byte range from content body
    final range = await content.byteData(40, 52);
    final rangeText = utf8.decode(Uint8List.sublistView(range));
    print('* Title from byte range for post 2 : ' + rangeText);

    // consume as text
    final text = await content.text;
    print('* JSON raw text for post 2 : ' + text);
  } on OriginException catch (e) {
    print('Origin exception: status code ${e.statusCode}');
  } catch (e) {
    print('Other exception: $e');
  }

  // fetch content as stream and then consume byte blocks coming from stream
  try {
    final content = await fetcher.fetchStream(Uri(path: 'posts/3'));
    await for (var bytes in await content.stream) {
      print('* Got ${bytes.length} bytes from post 3');
    }
  } on OriginException catch (e) {
    print('Origin exception: status code ${e.statusCode}');
  } catch (e) {
    print('Other exception: $e');
  }
}

Future<void> _httpFetcherWithClient() async {
  print('');
  print('Using HTTP fetcher with client.');

  // when creating http.Client, we must remember to close it after using it
  final client = http.Client();
  try {
    // now create a fetcher with the client just created and endpoints
    final fetcher = HttpFetcher.client(client,
            endpoints: [Uri.parse('https://jsonplaceholder.typicode.com/')])
        .headers({'user-agent': 'datatools-sample'});

    // fetch titles for posts 4 and 5 - both requests should use same client
    try {
      for (var id in [4, 5]) {
        final json = await fetcher.fetchJson(Uri(path: 'posts/$id'));
        print('* Title for post $id : ' + json['title']);
      }
    } on OriginException catch (e) {
      print('Origin exception: ' +
          (e.isNotFound ? 'not found' : 'status code ${e.statusCode}'));
    } catch (e) {
      print('Other exception: $e');
    }
  } finally {
    client.close();
  }
}

Future<void> _fileFetcher() async {
  print('');
  print('Using file fetcher.');

  // create a file fetcher with a directory as a base path
  final fetcher = FileFetcher.basePath('test');

  // fetch json from a file resource
  try {
    final json = await fetcher.fetchJson(Uri(path: 'file_test_data.json'));
    print('* Body for post 2 : ' + json['body']);
  } on OriginException catch (e) {
    print('Origin exception: ' + (e.isNotFound ? 'not found' : 'other'));
  } catch (e) {
    print('Other exception: $e');
  }
}

void _metadataStructures() {
  print('');
  print('Create some basic metadata structures.');

  // Link
  print(Link(
    href: 'http://example.com',
    rel: 'alternate',
    type: 'application/json',
    title: 'Other content',
  ));
}
