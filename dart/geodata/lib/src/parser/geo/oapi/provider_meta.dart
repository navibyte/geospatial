// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:geocore/geocore.dart';

import '../../../model/geo/common.dart';
import '../../../model/geo/links.dart';

/// Combines [ProviderMeta] information from different OAPIF metadata responses.
ProviderMeta providerFromJson({
  required Map<String, dynamic> landing,
  required Map<String, dynamic> conformance,
  required Map<String, dynamic> collections,
}) {
  final links = LinksMeta.fromJson(landing['links']);
  return ProviderMeta(
    links: links,
    conformance: conformanceFromJson(conformance),
    collections: collectionsFromJson(collections),
    title: landing['title'] ?? links.self()?.title ?? 'An OGC API service',
    description: landing['description'],
  );
}

/// Parses a '/conformance' meta data from a OGC API service.
List<String> conformanceFromJson(Map<String, dynamic> json) =>
    (json['conformsTo'] as List).cast<String>();

/// Parses a '/collections' meta data from a OGC API service.
List<CollectionMeta> collectionsFromJson(Map<String, dynamic> json) {
  final list = json['collections'] as List;
  return List.from(list.map((e) => collectionFromJson(e)));
}

/// Parses a '/collections/{collectionId}' meta data from a OGC API service.
CollectionMeta collectionFromJson(Map<String, dynamic> json) {
  final links = LinksMeta.fromJson(json['links']);
  final extent = json['extent'];
  final id = json['id'];
  return CollectionMeta(
    id: id,
    links: links,
    title: json['title'] ?? links.self()?.title ?? id,
    description: json['description'],
    extent: extent != null ? extentFromJson(extent) : null,
  );
}

/// Parses [Extent] data structure from a json snippet.
Extent extentFromJson(Map<String, dynamic> json) {
  final spatial = json['spatial'];
  final crs = CRS.id(spatial['crs'] ?? idCRS84);
  final allBounds = (spatial['bbox'] as List).map((e) => GeoBounds.from(e));
  final temporal = json['temporal'];
  if (temporal != null) {
    return Extent.multi(
        crs: crs,
        allBounds: allBounds,
        allIntervals:
            (temporal['interval'] as List).map((e) => Interval.fromJson(e)));
  } else {
    return Extent.multi(crs: crs, allBounds: allBounds);
  }
}
