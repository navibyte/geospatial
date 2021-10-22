// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:datatools/meta_link.dart';

import '../base.dart';

import 'collection_meta.dart';

/// Metadata for a data source (like an API service or other resource).
class DataSourceMeta extends ResourceMeta {
  /// Create metadata for a data source.
  const DataSourceMeta({
    required String title,
    String? description,
    required Links links,
    required this.conformance,
    required this.collections,
  }) : super(title: title, description: description, links: links);

  /// Create metadata for a data source from [collections] and optional [title].
  factory DataSourceMeta.collectionIds(
    Iterable<String> collectionIds, {
    required String title,
  }) =>
      DataSourceMeta(
        title: title,
        links: Links.empty(),
        conformance: const [],
        collections: collectionIds.map((id) => CollectionMeta.id(id)),
      );

  /// Conformance classes this data source is conforming to.
  final Iterable<String> conformance;

  /// Metadata about collection resources provided by this data source.
  final Iterable<CollectionMeta> collections;

  @override
  List<Object?> get props =>
      [title, description, links, conformance, collections];
}
