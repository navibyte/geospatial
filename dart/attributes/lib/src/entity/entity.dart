// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../collection.dart';

import 'identifier.dart';
import 'entity_base.dart';

/// An entity is a data object with optional [id] and required [properties].
abstract class Entity {
  const Entity();

  /// A new entity of optional [id] and required [properties].
  factory Entity.of({Identifier? id, required PropertyMap properties}) =>
      EntityBase(
        id: id,
        properties: properties,
      );

  /// A new entity of optional [id] and required source [properties].
  ///
  /// This factory allows [id] to be null or an instance of [Identifier],
  /// `String`, `int` or `BigInt`. In other cases an ArgumentError is thrown.
  ///
  /// The [properties] is used as a source view for an entity. Any changes on
  /// source reflect also on entity properties.
  factory Entity.view({dynamic id, required Map<String, dynamic> properties}) =>
      EntityBase(
        id: Identifier.idOrNull(id),
        properties: PropertyMap.view(properties),
      );

  /// An empty entity with empty properties and without id.
  factory Entity.empty() => EntityBase(properties: PropertyMap.empty());

  /// An optional [id] for this entity.
  Identifier? get id;

  /// The required [properties] for this entity, allowed to be empty.
  PropertyMap get properties;
}
