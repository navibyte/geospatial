// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'query.dart';

/// A known MIME (sub) type as an enumeration.
// ignore: constant_identifier_names
enum KnownType { unknown, html, json, ld_json, geo_json, xml, xml_gml }

/// MIME type information parsed from "content-type" and known by this package.
@immutable
class KnownMime with EquatableMixin {
  /// A known MIME [type] with optional [version] and [profile].
  const KnownMime(this.type, {this.version, this.profile});

  /// A known MIME (sub) type.
  final KnownType type;

  /// An optional version (like "3.2" for KnownType.xml.gml) speficifying type.
  final String? version;

  /// An optional profile speficifying type.
  final String? profile;

  @override
  List<Object?> get props => [type, version, profile];
}

/// An interface for accessing content requested from an API resource.
abstract class Content {
  const Content();

  /// The query referring to a resource the content represents.
  Query get query;

  /// The mime type for this content and known by this package.
  KnownMime get mime;

  /// The content type of this content (ie. raw "content-type" header value).
  ///
  /// The value can be any registered MIME type. Examples of typical values:
  /// `text/html`
  /// `application/json`
  /// `application/geo+json`
  /// `application/ld+json`
  /// `application/xml`
  /// `application/gml+xml;version=3.2``
  /// `application/gml+xml;version=3.2;profile=http://www.opengis.net/def/profile/ogc/2.0/gml-sf0`
  /// `application/gml+xml;version=3.2;profile=http://www.opengis.net/def/profile/ogc/2.0/gml-sf2`
  String get contentType;

  /// The content length (ie. the value of the "content-length" header)
  int get length;

  /// The content body as String.
  String body();

  /// The content body as bytes.
  Uint8List bodyBytes();

  /// The content decoded as JSON object.
  ///
  /// The result is an object tree as parsed by the standard `json.decode()` of
  /// the `dart:convert` package.
  dynamic decodeJson();

  /// Converts this content to the type [T] (or null if not supported).
  ///
  /// A null is returned when the converter does not support a conversion.
  ///
  /// An exception is thrown if the conversion fails.
  T? convert<T>() => query.convert<T>(this);
}
