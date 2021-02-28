// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

import 'package:datatools/fetch_http.dart';

import 'package:geodata/geojson_features.dart';
import 'package:geodata/oapi_features.dart';

/*
To test run this from command line: 

dart example/meta_example.dart https://demo.pygeoapi.io/master/
dart example/meta_example.dart https://www.ldproxy.nrw.de/kataster/
dart example/meta_example.dart https://weather.obs.fmibeta.com/

*/

/// A simple example to read metadata from standard OGC API Features services.
void main(List<String> args) async {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  // loop over all test URLs (from the arguments) and read meta data for each
  for (var baseURL in args) {
    try {
      final meta = await _readMeta(baseURL);
      _printSource(meta);
    } catch (e, st) {
      print('Calling $baseURL failed: $e');
      print(st);
    }
  }
}

Future<DataSourceMeta> _readMeta(String baseURL) async {
  // Create a feature provider for OGC API Features (OAPIF) using an API
  // client accessing an HTTP endpoint.
  final provider = FeatureServiceOAPIF.of(
    client: HttpFetcher.simple(
      endpoints: [Uri.parse(baseURL)],
    ),
  );

  // Read metadata
  return provider.meta();
}

void _printSource(DataSourceMeta meta) {
  print('');
  print('*****');
  _printResource(meta);
  final links = meta.links;
  if (links.self().isNotEmpty) {
    print('  BaseURL: ${links.self().first.href}');
  }
  var service = links.serviceDesc();
  if (service.isEmpty) {
    service = links.service();
  }
  if (service.isNotEmpty) {
    print('  API description: ${service.first.href}');
  }
  print('');
  print('Conformance classes:');
  meta.conformance.forEach((e) => print('  $e'));
  print('');
  print('Collections:');
  for (var coll in meta.collections) {
    _printCollection(coll);
  }
}

void _printCollection(CollectionMeta meta) {
  _printResource(meta);
  final extent = meta.extent;
  if (extent != null) {
    print('    extent crs: ${extent.crs.id}');
    for (var bounds in extent.allBounds) {
      print('    spatial bbox min: ${bounds.min.values}');
      print('    spatial bbox max: ${bounds.max.values}');
    }
    for (var interval in extent.allIntervals) {
      if (!interval.isOpen) {
        print('    temporal interval: $interval');
      }
    }
  }
}

void _printResource(ResourceMeta meta) {
  if (meta is CollectionMeta) {
    print('  ${meta.id} (${meta.title})');
  } else {
    print('  ${meta.title}');
  }
  if (meta.description != null) print('    ${meta.description}');
}
