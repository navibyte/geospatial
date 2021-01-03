// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'package:synchronized/synchronized.dart';

import 'package:geocore/base.dart';
import 'package:geocore/crs.dart';
import 'package:geocore/geo.dart';
import 'package:geocore/meta_extent.dart';
import 'package:geocore/parse_factory.dart';
import 'package:datatools/client_base.dart';

import '../../../model/common.dart';
import '../../../provider/common.dart';

/// A provider for data sources conforming to the OGC API Common standard.
///
/// See: https://ogcapi.ogc.org/common/
///
/// This is an abstract base provider that should be extended by concrete
/// implementations. For example [FeatureProviderOAPIF] extends [ProviderOAPI]
/// to to provide support for the OGC API Features standard.
abstract class ProviderOAPI<M extends ProviderMeta, C extends Resource>
    implements Provider<M, C> {
  ProviderOAPI({required this.client});

  /// The API client used by this OAPI provider.
  ///
  /// Should be used only by this class and sub classes, so marked @protected.
  @protected
  final ApiClient client;

  M? _meta;
  final _metaLock = Lock();

  @override
  Future<M> meta() async {
    return _meta ??= await _metaLock.synchronized<M>(() async {
      // read "/"
      final landing = await client.read(Query.url((e) => '${e.baseUrl}/'));
      final landingJson = landing.decodeJson();

      // read "/conformance"
      final conformance =
          await client.read(Query.url((e) => '${e.baseUrl}/conformance'));
      final conformanceJson = conformance.decodeJson();

      // read "/collections"
      final collections =
          await client.read(Query.url((e) => '${e.baseUrl}/collections'));
      final collectionsJson = collections.decodeJson();

      // combine ProviderMeta object from different meta resources just fetched
      return providerMetaFromJson(
        landing: landingJson,
        conformance: conformanceJson,
        collections: collectionsJson,
      );
    });
  }

  /// Combines meta from different metadata resources returning instance of [M].
  ///
  /// Should be used only by this class and sub classes, so marked @protected.
  @protected
  M providerMetaFromJson({
    required Map<String, dynamic> landing,
    required Map<String, dynamic> conformance,
    required Map<String, dynamic> collections,
  }) {
    final links = LinksMeta.fromJson(landing['links']);
    return createProviderMeta(
      links: links,
      conformance: _conformanceFromJson(conformance),
      collections: _collectionsFromJson(collections),
      title: landing['title'] ?? links.self()?.title ?? 'An OGC API service',
      description: landing['description'],
    );
  }

  /// Create an instance of [M] that is a type extending [ProviderMeta].
  ///
  /// Should be used only by this class and sub classes, so marked @protected.
  @protected
  M createProviderMeta(
      {required LinksMeta links,
      required List<String> conformance,
      required List<CollectionMeta> collections,
      required String title,
      String? description});
}

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

/// Parses a '/conformance' meta data from a OGC API service.
List<String> _conformanceFromJson(Map<String, dynamic> json) =>
    (json['conformsTo'] as List).cast<String>();

/// Parses a '/collections' meta data from a OGC API service.
List<CollectionMeta> _collectionsFromJson(Map<String, dynamic> json) {
  final list = json['collections'] as List;
  return List.from(list.map((e) => _collectionFromJson(e)));
}

/// Parses a '/collections/{collectionId}' meta data from a OGC API service.
CollectionMeta _collectionFromJson(Map<String, dynamic> json) {
  final links = LinksMeta.fromJson(json['links']);
  final extent = json['extent'];
  final id = json['id'] ?? json['name']; // "name" not really standard
  return CollectionMeta(
    id: id,
    links: links,
    title: json['title'] ?? links.self()?.title ?? id,
    description: json['description'],
    extent: extent != null ? _extentFromJson(extent) : null,
  );
}

/// Parses [Extent] data structure from a json snippet.
Extent _extentFromJson(Map<String, dynamic> json) {
  final spatial = json['spatial'];
  final spatialIsMap = spatial is Map<String, dynamic>;
  final crs = CRS.id((spatialIsMap ? spatial['crs'] : null) ?? idCRS84);

  // try to parse bboxes
  var allBounds;
  final bbox = spatialIsMap ? spatial['bbox'] : null;
  if (bbox != null && bbox is List) {
    // by standard: "bbox" is a list of bboxes
    allBounds = bbox.map((e) => createGeoBounds(e));
  } else {
    // not standard: assume "spatial" as one bbox
    try {
      allBounds = [createGeoBounds(spatial)];
    } catch (e) {
      // fallback
      allBounds = [GeoBounds.world()];
    }
  }

  // try to parse temporal intervals
  var allIntervals;
  final temporal = json['temporal'];
  if (temporal != null) {
    final interval =
        temporal is Map<String, dynamic> ? temporal['interval'] : null;
    if (interval != null && interval is List) {
      // by standard: "interval" is a list of intervals
      allIntervals = interval.map((e) => Interval.fromJson(e));
    } else {
      // not standard: assume "temporal" as one interval
      try {
        allIntervals = [Interval.fromJson(temporal)];
      } catch (e) {
        // no fallback need, just no temporal interval then
      }
    }
  }

  // combine to Extent
  if (allIntervals != null) {
    return Extent.multi(
      crs: crs,
      allBounds: allBounds,
      allIntervals: allIntervals,
    );
  } else {
    return Extent.multi(crs: crs, allBounds: allBounds);
  }
}

/*
  Some notes about how "extent" can be returned, one of these is not following
  standard maybe? Or still is a WFS3 not OAPIF? 
  
  https://www.ldproxy.nrw.de/kataster/collections?f=json  
  (Maybe still WFS 3.0)

    "extent" : {
      "spatial" : [ 5.61272621360749, 50.2373512077239, 9.58963433710139, 52.5286304537795 ],
      "temporal" : [ "2018-05-18T14:45:44Z", "2021-01-01T11:58:21Z" ]
    },

  https://demo.pygeoapi.io/master/collections?f=json 
  (OK according to OGC API Features)    

    "extent": {
        "spatial": {
            "bbox": [
                [
                    -180,
                    -90,
                    180,
                    90
                ]
            ],
            "crs": "http://www.opengis.net/def/crs/OGC/1.3/CRS84"
        },
        "temporal": {
            "interval": [
                [
                    "2000-10-30T18:24:39+00:00",
                    "2007-10-30T08:57:29+00:00"
                ]
            ]
        }
    },
*/
