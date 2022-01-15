// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print

import 'package:equatable/equatable.dart';
import 'package:geocore/data.dart';

import 'package:geodata/geojson_client.dart';
import 'package:geodata/ogcapi_features_client.dart';

/*
To test run this from command line: 

GeoJSON (web / http) resource as a data source:
dart example/geodata_example.dart geojson https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/ 2.5_day.geojson,significant_week.geojson 3 items
dart example/geodata_example.dart geojson https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/ significant_week.geojson 3 items id us7000gaqu

OGC API Features data sources:
dart example/geodata_example.dart ogcfeat https://demo.pygeoapi.io/master/ lakes 2 items
dart example/geodata_example.dart ogcfeat https://demo.pygeoapi.io/master/ lakes 2 items id 3
dart example/geodata_example.dart ogcfeat https://www.ldproxy.nrw.de/kataster/ verwaltungseinheit 2 items bbox 7,50.6,7.2,50.8
dart example/geodata_example.dart ogcfeat https://weather.obs.fmibeta.com/ fmi_aws_observations 2 items bbox 23,62,24,63

OGC API Features meta queries:
dart example/geodata_example.dart ogcfeat https://demo.pygeoapi.io/master/ - 1 meta
dart example/geodata_example.dart ogcfeat https://www.ldproxy.nrw.de/kataster/ - 1 meta
dart example/geodata_example.dart ogcfeat https://weather.obs.fmibeta.com/ - 1 meta

More demo APIs (however this page seems to be somewhat outdated, be careful!):
https://github.com/opengeospatial/ogcapi-features/tree/master/implementations
*/

const _defaultOperation = 'items';
const _defaultLimit = 2;
const _defaultMaxPagedResults = 2;

/// A simple example to read features from standard OGC API Features services.
Future<void> main(List<String> args) async {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  // check enough args
  if (args.length < 3) {
    print(
      'Args: {service} {baseUrl} {collectionIds} '
      '[limit] [operation] [param] [value]',
    );
    print('Allowed sources: oapif, geojson');
    return;
  }

  // parse args
  final serviceType = args[0];
  final baseURL = args[1];
  final collectionIds = args[2].split(',');
  final limit = args.length >= 4 ? int.tryParse(args[3]) : _defaultLimit;
  final operation = args.length >= 5 ? args[4] : _defaultOperation;
  var maxPagedResults = _defaultMaxPagedResults;

  // parse query
  GeospatialQuery query = BoundedItemsQuery(limit: limit);

  if (args.length >= 7) {
    switch (args[5]) {
      case 'id':
        query = ItemQuery(
          id: args[6],
        );
        maxPagedResults = 1;
        break;
      case 'bbox':
        if (serviceType != 'geojson') {
          final bbox = args[6].split(',');
          if (bbox.length == 4 || bbox.length == 6) {
            query = BoundedItemsQuery(
              limit: limit,
              bounds: GeoBounds.from(bbox.map<num>(double.parse)),
            );
          }
        }
        break;
    }
  }

  try {
    // Create a feature service and apply an operation on it.
    switch (serviceType) {
      case 'geojson':
        // Loop over all collections (here sub resources like "2.5_day.geojson")
        for (final collectionId in collectionIds) {
          // A location to read GeoJSON data from.
          final location = Uri.parse(baseURL).resolve(collectionId);

          print('');
          print('Reading web resource at: $location');

          // GeoJSON client for a data source
          final source = geoJsonHttpClient(location: location);
          switch (operation) {
            case 'items':
              // get actual data, a single feature or features
              if (query is BoundedItemsQuery) {
                await _callItemsPaged(source, query, maxPagedResults);
              } else if (query is ItemQuery) {
                await _callItemById(source, query);
              }
              break;
            default:
              throw ArgumentError('Unknow operation $operation');
          }
        }
        break;
      case 'ogcfeat':
        // An enpoint to read data from.
        final endpoint = Uri.parse(baseURL);

        // OGC API Features client (the service provides both meta and items)
        final service = ogcApiFeaturesHttpClient(endpoint: endpoint);

        switch (operation) {
          case 'meta':
            // read landing page
            final meta = await service.meta();
            print('OGC API Features service:');
            _printMeta(meta);

            // read conformance classes
            final conformance = await service.conformance();
            _printConformance(conformance);

            // read meta about collections
            print('Collections:');
            final collections = await service.collections();
            for (final coll in collections) {
              _printCollection(coll);
            }
            break;
          case 'items':
            // Loop over all collections
            for (final collectionId in collectionIds) {
              // get feature source for a collection
              final source = await service.collection(collectionId);

              // read meta for this collection
              final meta = await source.meta();
              print('Collection meta:');
              _printCollection(meta);

              // get actual data, a single feature or features
              if (query is BoundedItemsQuery) {
                await _callItemsPaged(source, query, maxPagedResults);
              } else if (query is ItemQuery) {
                await _callItemById(source, query);
              }
            }
            break;
          default:
            throw ArgumentError('Unknow operation $operation');
        }
        break;
      default:
        throw ArgumentError('Unknow source type $serviceType');
    }
  } on FeatureException catch (e) {
    print('Calling $baseURL failed: ${e.failure.name}');
    if (e.cause != null) {
      print('Cause: ${e.cause}');
    }
    if (e.trace != null) {
      print(e.trace);
    }
  } catch (e, st) {
    print('Calling $baseURL failed: $e');
    print(st);
  }
}

Future<bool> _callItemById(
  BasicFeatureSource source,
  ItemQuery query,
) async {
  // fetch feature item
  final item = source is FeatureSource
      ? await source.item(query)
      : await source.itemById(query.id);
  _printFeature(item.feature);
  return true;
}

Future<bool> _callItemsPaged(
  BasicFeatureSource source,
  BoundedItemsQuery query,
  int maxPagedResults,
) async {
  // fetch feature items as paged results, max rounds by maxPagedResults
  var round = 0;
  Paged<FeatureItems>? page;
  if (source is FeatureSource) {
    page = await source.itemsPaged(query);
  } else {
    page = await source.itemsAllPaged(limit: query.limit);
  }
  while (page != null && round++ < maxPagedResults) {
    _printFeatures(page.current);
    page = await page.next();
  }
  return true;
}

void _printFeatures(FeatureItems items) {
  print('Features:');
  if (items is OGCFeatureItems) {
    if (items.timeStamp != null) {
      print('  timestamp: ${items.timeStamp}');
    }
    if (items.numberMatched != null) {
      print('  number matched: ${items.numberMatched}');
    }
    if (items.numberReturned != null) {
      print('  number returned: ${items.numberReturned}');
    }
    _printLinks(items.links);
  }
  items.collection.features.forEach(_printFeature);
}

void _printFeature(Feature f) {
  print('Feature with id: ${f.id}');
  print('  geometry: ${f.geometry}');
  print('  properties:');
  for (final key in f.properties.keys) {
    print('    $key: ${f.properties[key]}');
  }
}

void _printMeta(ResourceMeta meta) {
  print('  title: ${meta.title}');
  if (meta.description != null) {
    print('  description: ${meta.description}');
  }
}

void _printConformance(Iterable<String> conformance) {
  print('Conformance classes:');
  for (final e in conformance) {
    print('  $e');
  }
}

void _printLinks(Links links) {
  if (links.all.isNotEmpty) {
    print('  Links:');
    for (final link in links.all) {
      print('    ${link.rel} : ${link.href}');
    }
  }
}

void _printCollection(CollectionMeta meta) {
  _printResource(meta);
  final extent = meta.extent;
  if (extent != null) {
    print('    extent crs: ${extent.crs}');
    for (final bounds in extent.allBounds) {
      print('    spatial bbox min: ${bounds.min.values}');
      print('    spatial bbox max: ${bounds.max.values}');
    }
    for (final interval in extent.allIntervals) {
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
  if (meta.description != null) {
    print('    ${meta.description}');
  }
}
