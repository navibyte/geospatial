// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:datatools/meta_link.dart';

import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

/// Basic meta data about some resource.
@immutable
class ResourceMeta with EquatableMixin {
  /// A new resource metadata element with [title], [description] and [links].
  const ResourceMeta(
      {required this.title, this.description, required this.links});

  /// A required title for a meta element.
  final String title;

  /// An optional description for a meta element.
  final String? description;

  /// The required links for a resource (allowed to be empty).
  final Links links;

  @override
  List<Object?> get props => [title, description, links];
}
