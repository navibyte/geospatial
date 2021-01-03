// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import '../collection.dart';

import 'identifier.dart';
import 'entity.dart';

/// An immutable base implementation of [Entity].
@immutable
class EntityBase extends Entity with EquatableMixin {
  /// A new entity of optional [id] and required [properties].
  ///
  /// The [properties] is required, but allowed to be empty.
  const EntityBase({this.id, required this.properties});

  @override
  final Identifier? id;

  @override
  final PropertyMap properties;

  // Note: [props] is from [EquatableMixin] and is different from [properties].
  @override
  List<Object?> get props => [id, properties];
}
