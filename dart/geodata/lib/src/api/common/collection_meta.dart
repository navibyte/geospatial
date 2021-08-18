// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:attributes/values.dart';
import 'package:datatools/meta_link.dart';
import 'package:geocore/meta_extent.dart';

import '../base.dart';

/// Metadata for a collection resource.
///
/// The [id] of the collection can be used as a path segment in URIs.
class CollectionMeta extends ResourceMeta {
  /// Create a meta instance.
  const CollectionMeta(
      {required this.id,
      required String title,
      String? description,
      required Links links,
      this.extent})
      : super(title: title, description: description, links: links);

  /// Create a meta instance from [id] and an optional [title].
  factory CollectionMeta.id(String id, {String? title}) => CollectionMeta(
        id: Identifier.fromString(id),
        links: Links.empty(),
        title: title ?? id,
      );

  /// The required [id] of the collection.
  ///
  /// In some APIs this [id] could be used as a path segment on URI references.
  final Identifier id;

  /// An optional geospatial [extent] for this collection.
  final Extent? extent;

  @override
  List<Object?> get props => [id, title, description, links, extent];
}
