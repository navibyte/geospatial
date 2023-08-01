// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

/// Represents `Queryables` document for an OGC API service parsed from JSON
/// Schema data.
///
/// Note: this class wraps decoded JSON Object from a JSON document containing
/// JSON Schema data. To utilize such data JSON Object tree in [content] can
/// be traversed as needed.
///
/// This class provides also decoded attributes like [title], [description],
/// [additionalProperties] and [properties] originating from JSON Schema data
/// and referenced by the `OGC API - Features - Part 3: Filtering` standard.
/// These attributes do not cover all use cases described in the standard
/// however, so for certain special use cases original JSON Schema tree in
/// [content] might be needed.
///
/// See also:
/// * https://github.com/opengeospatial/ogcapi-features (see Part 3 / Filtering)
/// * https://json-schema.org/
@immutable
class OGCQueryableObject {
  const OGCQueryableObject._({
    required this.content,
    required this.id,
    required this.schemaId,
    required this.title,
    this.description,
    this.additionalProperties = true,
    required this.properties,
  });

  /// Parses `Queryables` document for an OGC API service from JSON Schema based
  /// data in [content].
  factory OGCQueryableObject.fromJson(Map<String, dynamic> content) {
    if ((content['type'] as String).toLowerCase() != 'object') {
      throw const FormatException('Not valid JSON Schema type.');
    }

    final properties = content['properties'];
    return OGCQueryableObject._(
      content: content,
      id: content[r'$id'] as String, // required
      schemaId: content[r'$schema'] as String, // required
      title: content['title'] as String? ?? 'Queryables',
      description: content['description'] as String?,
      additionalProperties: content['additionalProperties'] as bool? ?? true,
      properties: properties != null && properties is Map<String, dynamic>
          ? OGCQueryableProperty._parseMap(properties)
          : <String, OGCQueryableProperty>{},
    );
  }

  /// JSON Schema based data representing `Queryables` document for an OGC API
  /// service.
  ///
  /// This is data that is directly parsed from JSON Schema data an OGC API
  /// Service has published. Use this for more detailed inspection of
  /// Queryables metadata when other class members are not enough.
  final Map<String, dynamic> content;

  /// The URI of the resource without query parameters.
  final String id;

  /// The schema id of JSON Schema data in content.
  ///
  /// Should be either "https://json-schema.org/draft/2019-09/schema" or
  /// "https://json-schema.org/draft/2020-12/schema" according to the
  /// `OGC API - Features - Part 3: Filtering` standard.
  final String schemaId;

  /// The human readable title for this queryable object.
  final String title;

  /// An optional human readable description.
  final String? description;

  /// If true, any properties are valid in filter expressions even when not
  /// declared in a queryable schema.
  final bool additionalProperties;

  /// A map of queryable properties for this queryable object.
  ///
  /// The map key represents a property name (that is accessible also from
  /// the `name` property of `OGCQueryableProperty` object).
  ///
  /// NOTE: currently this contains only non-geospatial properties that SHOULD
  /// have at least "type" and "title" attributes.
  final Map<String, OGCQueryableProperty> properties;

  @override
  String toString() => content.toString();

  @override
  bool operator ==(Object other) =>
      other is OGCQueryableObject && content == other.content;

  @override
  int get hashCode => content.hashCode;
}

/// A queryable non-geospatial property.
@immutable
class OGCQueryableProperty {
  const OGCQueryableProperty._({
    required this.name,
    required this.title,
    this.description,
    required this.type,
  });

  static Map<String, OGCQueryableProperty> _parseMap(
    Map<String, dynamic> properties,
  ) {
    final map = <String, OGCQueryableProperty>{};

    for (final entry in properties.entries) {
      final name = entry.key;
      final def = entry.value;
      if (def is Map<String, dynamic>) {
        final type = def['type'];
        if (type != null && type is String) {
          map[name] = OGCQueryableProperty._(
            name: name,
            title: def['title'] as String? ?? name,
            description: def['description'] as String?,
            type: type,
          );
        }
      }
    }

    return map;
  }

  /// The property name.
  final String name;

  /// The human readable title for this property.
  final String title;

  /// An optional human readable description.
  final String? description;

  /// The type for this property.
  ///
  /// According to the `OGC API - Features - Part 3: Filtering` standard a type
  /// SHOULD be one of the following:
  /// * `string` (string or temporal properties)
  /// * `number` / `integer` (numeric properties)
  /// * `boolean` (boolean properties)
  /// * `array` (array properties)
  ///
  /// In practise different OGC API Features implementations seem also to use
  /// different specifiers for types.
  final String type;

  @override
  String toString() =>
      '{name: $name, title: $title, description: $description, type: $type}';

  @override
  bool operator ==(Object other) =>
      other is OGCQueryableProperty &&
      name == other.name &&
      title == other.title &&
      description == other.description &&
      type == other.type;

  @override
  int get hashCode => Object.hash(name, title, description, type);
}
