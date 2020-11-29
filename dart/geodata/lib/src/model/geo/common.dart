// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import 'package:geocore/meta.dart';

import 'links.dart';

/// Base meta with [title] and [description].
@immutable
class Meta with EquatableMixin {
  const Meta({required this.title, this.description});

  /// A required title for a meta element.
  final String title;

  /// An optional description for a meta element.
  final String? description;

  @override
  List<Object?> get props => [title, description];
}

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

/// Metadata for a collection resource.
class CollectionMeta extends Meta {
  const CollectionMeta(
      {required this.id,
      required this.links,
      this.extent,
      required String title,
      String? description})
      : super(title: title, description: description);

  /// The identifier for the collection. Can be used as a path segment in URIs.
  final String id;

  /// Links for the collection.
  final LinksMeta links;

  /// Geospatial extent for this dataset.
  final Extent? extent;

  @override
  List<Object?> get props => [id, extent, title, description];
}
