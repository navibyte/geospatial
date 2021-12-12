// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:datatools/fetch_api.dart';
import 'package:datatools/meta_link.dart';
import 'package:geocore/base.dart';
import 'package:geocore/crs.dart';
import 'package:geocore/geo.dart';
import 'package:geocore/meta_extent.dart';

import 'package:meta/meta.dart';

import 'package:synchronized/synchronized.dart';

import '../../api/common.dart';

/// A data source conforming to the OGC API Common standard.
///
/// See: https://ogcapi.ogc.org/common/
///
/// This is an abstract base data source that should be extended by concrete
/// implementations. For example `FeatureSourceOAPIF` extends [DataSourceOAPI]
/// to to provide support for the OGC API Features standard.
abstract class DataSourceOAPI<M extends DataSourceMeta>
    implements DataSource<M> {
  /// Default `const` constructor to allow extending this abstract class.
  DataSourceOAPI({required this.client});

  M? _meta;
  final _metaLock = Lock();

  /// The [client] to fetch data from resources.
  @protected
  final Fetcher client;

  @override
  Future<M> meta() async => _meta ??= await _metaLock.synchronized<M>(() async {
        // a client accepting JSON content
        final c = client.headers({'accept': 'application/json'});

        // combine meta object from different meta resources just fetched
        return metaFromJson(
          // read the landing page of OAPI service
          landing: await c.fetchJson(Uri(path: '')) as Map<String, dynamic>,

          // read "conformance"
          conformance: await c.fetchJson(Uri(path: 'conformance'))
              as Map<String, dynamic>,

          // read "collections"
          collections: await c.fetchJson(Uri(path: 'collections'))
              as Map<String, dynamic>,
        );
      });

  /// Combines meta from different metadata resources returning instance of [M].
  ///
  /// Should be used only by this class and sub classes, so marked @protected.
  @protected
  M metaFromJson({
    required Map<String, dynamic> landing,
    required Map<String, dynamic> conformance,
    required Map<String, dynamic> collections,
  }) {
    final links = Links.fromJson(landing['links'] as List);
    return createMeta(
      links: links,
      conformance: _conformanceFromJson(conformance),
      collections: _collectionsFromJson(collections),
      title: landing['title'] as String? ??
          links.self().first.title ??
          'An OGC API service',
      description: landing['description'] as String?,
    );
  }

  /// Create an instance of [M] that is a type extending [DataSourceMeta].
  ///
  /// Should be used only by this class and sub classes, so marked @protected.
  @protected
  M createMeta({
    required String title,
    String? description,
    required Links links,
    required List<String> conformance,
    required List<CollectionMeta> collections,
  });
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
  return List.from(
    list.map<CollectionMeta>(
      (dynamic e) => _collectionFromJson(e as Map<String, dynamic>),
    ),
  );
}

/// Parses a '/collections/{collectionId}' meta data from a OGC API service.
CollectionMeta _collectionFromJson(Map<String, dynamic> json) {
  final links = Links.fromJson(json['links'] as List);
  final extent = json['extent'] as Map<String, dynamic>?;
  final id = json['id'] as String? ??
      json['name'] as String; // "name" not really standard
  return CollectionMeta(
    id: id,
    title: json['title'] as String? ?? links.self().first.title ?? id,
    description: json['description'] as String?,
    links: links,
    extent: extent != null ? _extentFromJson(extent) : null,
  );
}

/// Parses [Extent] data structure from a json snippet.
Extent _extentFromJson(Map<String, dynamic> json) {
  final dynamic spatial = json['spatial'];
  final spatialIsMap = spatial is Map<String, dynamic>;
  final crs = CRS.id(
    (spatialIsMap
            ? (spatial as Map<String, dynamic>)['crs'] as String?
            : null) ??
        idCRS84,
  );

  // try to parse bboxes
  Iterable<GeoBounds> allBounds;
  final bbox =
      spatialIsMap ? (spatial as Map<String, dynamic>)['bbox'] as List? : null;
  if (bbox != null) {
    // by standard: "bbox" is a list of bboxes
    allBounds =
        bbox.map((dynamic e) => GeoBounds.from((e as Iterable).cast<num>()));
  } else {
    // not standard: assume "spatial" as one bbox
    try {
      allBounds = [GeoBounds.from((spatial as Iterable).cast<num>())];
    } on Exception {
      // fallback
      allBounds = [const GeoBounds.world()];
    }
  }

  // try to parse temporal intervals
  Iterable<Interval>? allIntervals;
  final dynamic temporal = json['temporal'];
  if (temporal != null) {
    final dynamic interval =
        temporal is Map<String, dynamic> ? temporal['interval'] : null;
    if (interval != null && interval is List) {
      // by standard: "interval" is a list of intervals
      allIntervals =
          interval.map((dynamic e) => Interval.fromJson(e as Iterable));
    } else {
      // not standard: assume "temporal" as one interval
      try {
        allIntervals = [Interval.fromJson(temporal as Iterable)];
      } on Exception {
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
      "spatial" : [ 5.61272621360749, 50.2373512077239, 9.58963433710139, 
                    52.5286304537795 ],
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
