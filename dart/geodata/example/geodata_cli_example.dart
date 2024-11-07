// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:geobase/common.dart';
import 'package:geobase/coordinates.dart';
import 'package:geobase/vector_data.dart';

import 'package:geodata/geojson_client.dart';
import 'package:geodata/ogcapi_features_client.dart';

import 'package:geodata/src/utils/resolve_api_call.dart';

/*
To test run this from command line: 

GeoJSON (web / http) resource as a data source:
dart example/geodata_cli_example.dart geojson https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/ 2.5_day.geojson,significant_week.geojson 3 items
dart example/geodata_cli_example.dart geojson https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/ significant_month.geojson 3 items id ok2022cedc

OGC API Features service meta queries:
dart example/geodata_cli_example.dart ogcfeat https://demo.pygeoapi.io/master/ - 1 meta
dart example/geodata_cli_example.dart ogcfeat https://weather.obs.fmibeta.com/ - 1 meta
dart example/geodata_cli_example.dart ogcfeat https://demo.ldproxy.net/zoomstack - 1 meta

OGC API Features meta and queryables from collections:
dart example/geodata_cli_example.dart ogcfeat https://demo.pygeoapi.io/master/ lakes,obs,dutch_windmills 1 collection
dart example/geodata_cli_example.dart ogcfeat https://weather.obs.fmibeta.com/ fmi_aws_observations 1 collection
dart example/geodata_cli_example.dart ogcfeat https://demo.ldproxy.net/zoomstack airports 1 collection

OGC API Features feature items from collections:
dart example/geodata_cli_example.dart ogcfeat https://demo.pygeoapi.io/master/ lakes 2 items
dart example/geodata_cli_example.dart ogcfeat https://demo.pygeoapi.io/master/ lakes 2 items id 3
dart example/geodata_cli_example.dart ogcfeat https://weather.obs.fmibeta.com/ fmi_aws_observations 2 items bbox 23,62,24,63
dart example/geodata_cli_example.dart ogcfeat https://demo.ldproxy.net/zoomstack airports 2 items

OGC API Features feature items from collections using CQL2:
dart example/geodata_cli_example.dart ogcfeat https://demo.ldproxy.net/zoomstack airports 2 items cql cql2-text - "name='London Oxford Airport'"

More OGC API Features implementations:
https://github.com/opengeospatial/ogcapi-features/tree/master/implementations
*/

const _defaultOperation = 'items';
const _defaultLimit = 2;
const _defaultMaxPagedResults = 2;

/// A simple CLI to read features from standard OGC API Features services.
Future<void> main(List<String> args) async {
  // check enough args
  if (args.length < 3) {
    print(
      'Args: {service} {baseUrl} {collectionIds} '
      '[limit] [operation] [param] [value]',
    );
    print('Allowed sources: ogcfeat, geojson');
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
  CQLQuery? cql;

  if (args.length >= 7) {
    switch (args[5]) {
      case 'id':
        query = ItemQuery(
          id: int.tryParse(args[6]) ?? args[6],
        );
        maxPagedResults = 1;
        break;
      case 'bbox':
        if (serviceType != 'geojson') {
          final bbox = args[6].split(',');
          if (bbox.length == 4 || bbox.length == 6) {
            final is3D = bbox.length == 6;
            query = BoundedItemsQuery(
              limit: limit,
              bbox: is3D
                  ? GeoBox(
                      west: double.parse(bbox[0]),
                      south: double.parse(bbox[1]),
                      minElev: double.parse(bbox[2]),
                      east: double.parse(bbox[3]),
                      north: double.parse(bbox[4]),
                      maxElev: double.parse(bbox[5]),
                    )
                  : GeoBox(
                      west: double.parse(bbox[0]),
                      south: double.parse(bbox[1]),
                      east: double.parse(bbox[2]),
                      north: double.parse(bbox[3]),
                    ),
            );
          }
        }
        break;
      case 'cql':
        if (args.length >= 9) {
          final filterLang = args[6];
          final filterCrs =
              args[7] == '-' ? null : CoordRefSys.normalized(args[7]);
          switch (filterLang) {
            case CQLQuery.filterLangCQL2Text:
              cql = CQLQuery.fromText(
                args[8],
                filterCrs: filterCrs,
              );
              break;
            case CQLQuery.filterLangCQL2Json:
              cql = CQLQuery.fromJson(
                json.decode(args[8]) as Map<String, dynamic>,
                filterCrs: filterCrs,
              );
              break;
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
          final location = resolveSubResource(Uri.parse(baseURL), collectionId);

          print('');
          print('Reading web resource at: $location');

          // GeoJSON client for a data source
          final source = GeoJSONFeatures.http(location: location);
          switch (operation) {
            case 'items':
              // get actual data, a single feature or features
              if (query is BoundedItemsQuery) {
                await _callItemsPaged(source, query, null, maxPagedResults);
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
        final service = OGCAPIFeatures.http(endpoint: endpoint);

        switch (operation) {
          case 'meta':
            // read landing page
            final meta = await service.meta();
            print('OGC API Features service:');
            _printMeta(meta);

            // read OpenAPI definition
            final openAPI = await meta.openAPI();
            _printOpenAPI(openAPI);

            // read conformance classes
            final conformance = await service.conformance();
            _printConformance(conformance.classes);

            // read meta about collections
            print('Collections:');
            final collections = await service.collections();
            for (final coll in collections) {
              _printCollection(coll);
            }
            break;
          case 'collection':
            // Loop over all collections
            for (final collectionId in collectionIds) {
              // get feature source for a collection
              final source = await service.collection(collectionId);

              // read meta for this collection
              final meta = await source.meta();
              print('Collection meta:');
              _printCollection(meta);

              // optional metadata about queryable properties
              final queryables = await source.queryables();
              if (queryables != null) {
                // got queryables
                _printQueryables(queryables);
              }
            }
            break;
          case 'items':
            // Loop over all collections
            for (final collectionId in collectionIds) {
              // get feature source for a collection
              final source = await service.collection(collectionId);

              // get actual data, a single feature or features
              if (query is BoundedItemsQuery) {
                await _callItemsPaged(source, query, cql, maxPagedResults);
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
  } on ServiceException<FeatureFailure> catch (e) {
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
  CQLQuery? cql,
  int maxPagedResults,
) async {
  // fetch feature items as paged results, max rounds by maxPagedResults
  var round = 0;
  Paged<FeatureItems>? page;
  if (source is OGCFeatureSource) {
    page = await source.itemsPaged(query, cql: cql);
  } else if (source is FeatureSource) {
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

void _printQueryables(OGCQueryableObject queryables) {
  print('Queryables for ${queryables.title}:');
  for (final prop in queryables.properties.values) {
    print('  ${prop.name} (${prop.title}): ${prop.type}');
  }
}

void _printOpenAPI(OpenAPIDocument document) {
  print('OpenAPI ${document.openapi}');
  final servers = document.content['servers'] as Iterable<dynamic>;
  for (final s in servers) {
    final server = s as Map<String, dynamic>;
    final url = server['url'] as String;
    final desc = server['description'] as String?;
    print('  $url : $desc');
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

void _printCollection(OGCCollectionMeta meta) {
  _printResource(meta);

  final supported = meta.crs;
  print('    supported CRS identifiers:');
  var i = 0;
  for (final crs in supported) {
    print('      $crs');
    if (++i >= 10) break;
  }

  if (meta.storageCrs != null) {
    print('    storageCrs: ${meta.storageCrs}');
  }
  if (meta.storageCrsCoordinateEpoch != null) {
    print('    storageCrsCoordinateEpoch: ${meta.storageCrsCoordinateEpoch}');
  }

  final extent = meta.extent;
  if (extent != null) {
    print('    extent crs: ${extent.spatial.crs}');
    for (final bounds in extent.spatial.boxes) {
      print('    spatial bbox min: ${bounds.min}');
      print('    spatial bbox max: ${bounds.max}');
    }
    final temporal = extent.temporal;
    if (temporal != null) {
      for (final interval in temporal.intervals) {
        if (!interval.isOpen) {
          print('    temporal interval: $interval');
        }
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
  if (meta.attribution != null) {
    print('    ${meta.attribution}');
  }
}
