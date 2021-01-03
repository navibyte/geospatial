// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../base.dart';

import 'collection_meta.dart';
import 'links_meta.dart';

/// Metadata for a data source or API provider.
class ProviderMeta extends Meta {
  const ProviderMeta(
      {required this.links,
      required this.conformance,
      required this.collections,
      required String title,
      String? description})
      : super(title: title, description: description);

  /// Links for the provider.
  final LinksMeta links;

  /// Conformance classes as a String list.
  final List<String> conformance;

  /// Metadata about collection resources provided by this provider.
  final List<CollectionMeta> collections;

  @override
  List<Object?> get props => [title, description, collections];
}
