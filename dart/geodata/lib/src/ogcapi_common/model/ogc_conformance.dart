// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

/// A wrapper for conformance classes for a OGC API Common compliant service.
///
/// See [OGC API Common](https://github.com/opengeospatial/ogcapi-common).
///
/// This class can be used to check conformance classes for:
/// * `OGC API - Common - Part 1: Core`
/// * `OGC API - Common - Part 2: Geospatial Data`
@immutable
class OGCConformance {
  /// Conformance classes a service is conforming to.
  final Iterable<String> classes;

  /// Creates a wrapper for conformance classes a service is conforming to.
  const OGCConformance(this.classes);

  /// Check whether a service conforms to the `Core` conformance class of the
  /// `OGC API - Common - Part 1: Core` standard.
  ///
  /// Optionally also check whether it supports [landingPage], [json], [html]
  /// and/or [openAPI30].
  ///
  /// Examples:
  /// ```dart
  ///   // Require the `Core` conformance class. Other classes could be
  ///   // supported or not.
  ///   conformsToCommonCore();
  ///
  ///   // Require `Core` and `JSON` conformance classes. Other classes
  ///   // could be supported or not.
  ///   conformsToCommonCore(json: true);
  ///
  ///   // Require `Core` and `JSON` conformance classes, and require
  ///   // NOT conforming to `HTML`. Other classes could be supported or not.
  ///   conformsToCommonCore(json: true, html: false);
  /// ```
  bool conformsToCommonCore({
    bool? landingPage,
    bool? json,
    bool? html,
    bool? openAPI30,
  }) {
    var isCore = false;
    var isLandingPage = false;
    var isJSON = false;
    var isHTML = false;
    var isOpenAPI30 = false;

    for (final id in classes) {
      if (!isCore && id == common1Core) {
        isCore = true;
      }
      if (!isLandingPage && id == common1LandingPage) {
        isLandingPage = true;
      }
      if (!isHTML && id == common1HTML) {
        isHTML = true;
      }
      if (!isJSON && id == common1JSON) {
        isJSON = true;
      }
      if (!isOpenAPI30 && id == common1OpenAPI30) {
        isOpenAPI30 = true;
      }
    }

    return isCore &&
        (landingPage == null || isLandingPage == landingPage) &&
        (json == null || isJSON == json) &&
        (html == null || isHTML == html) &&
        (openAPI30 == null || isOpenAPI30 == openAPI30);
  }

  /// Check whether a service conforms to the `Collections` conformance class of
  /// the `OGC API - Common - Part 2: Geospatial Data` standard.
  ///
  /// Optionally also check whether it supports [simpleQuery], [json] and/or
  /// [html].
  ///
  /// Examples:
  /// ```dart
  ///   // Require the `Collections` conformance class. Other classes could be
  ///   // supported or not.
  ///   conformsToCommonCollections();
  ///
  ///   // Require `Collections` and `JSON` conformance classes. Other classes
  ///   // could be supported or not.
  ///   conformsToCommonCollections(json: true);
  ///
  ///   // Require `Collections` and `JSON` conformance classes, and require
  ///   // NOT conforming to `HTML`. Other classes could be supported or not.
  ///   conformsToCommonCollections(json: true, html: false);
  /// ```
  bool conformsToCommonCollections({
    bool? simpleQuery,
    bool? json,
    bool? html,
  }) {
    var isCollections = false;
    var isSimpleQuery = false;
    var isJSON = false;
    var isHTML = false;

    for (final id in classes) {
      if (!isCollections && id == common2Collections) {
        isCollections = true;
      }
      if (!isSimpleQuery && id == common2SimpleQuery) {
        isSimpleQuery = true;
      }
      if (!isHTML && id == common2HTML) {
        isHTML = true;
      }
      if (!isJSON && id == common2JSON) {
        isJSON = true;
      }
    }

    return isCollections &&
        (simpleQuery == null || isSimpleQuery == simpleQuery) &&
        (json == null || isJSON == json) &&
        (html == null || isHTML == html);
  }

  @override
  String toString() => (StringBuffer()..writeAll(classes, ',')).toString();

  @override
  bool operator ==(Object other) {
    if (other is OGCConformance) {
      if (classes.length != other.classes.length) return false;
      final iter = other.classes.iterator;
      for (final item in classes) {
        if (!iter.moveNext()) return false;
        if (item != iter.current) return false;
      }
      return true;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll(classes);

  /// The `Core` conformance class for the
  /// `OGC API - Common - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/core`
  ///
  /// External dependencies:
  /// * [RFC 7231 (HTTP/1.1)](https://www.rfc-editor.org/info/rfc7231)
  /// * [RFC 2818 (HTTP over TLS)](https://www.rfc-editor.org/info/rfc2818)
  /// * [RFC 8288 (Web Linking)](https://www.rfc-editor.org/info/rfc8288)
  static const common1Core =
      'http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/core';

  /// The `Landing Page` conformance class for the
  /// `OGC API - Common - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/landing-page`
  ///
  /// Dependencies to other conformance classes:
  /// * [common1Core]
  static const common1LandingPage =
      'http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/landing-page';

  /// The `JSON` conformance class for the
  /// `OGC API - Common - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/json`
  ///
  /// Dependencies to other conformance classes:
  /// * [common1Core]
  /// * [common1LandingPage]
  ///
  /// External dependencies:
  /// * [IETF RFC 8259, The JavaScript Object Notation (JSON) Data Interchange Format](https://tools.ietf.org/rfc/rfc8259.txt)
  /// * [JSON Schema](https://json-schema.org/specification.html)
  static const common1JSON =
      'http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/json';

  /// The `HTML` conformance class for the
  /// `OGC API - Common - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/html`.
  ///
  /// Dependencies to other conformance classes:
  /// * [common1Core]
  /// * [common1LandingPage]
  ///
  /// External dependencies:
  /// * [HTML5](https://www.w3.org/TR/html5/)
  /// * [Schema.org](https://schema.org/docs/schemas.html)
  static const common1HTML =
      'http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/html';

  /// The `OpenAPI 3.0` conformance class for the
  /// `OGC API - Common - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common/1.0/req/oas30`.
  ///
  /// Dependencies to other conformance classes:
  /// * [common1Core]
  /// * [common1LandingPage]
  static const common1OpenAPI30 =
      'http://www.opengis.net/spec/ogcapi-common/1.0/req/oas30';

  /// The `Collections` conformance class for the
  /// `OGC API - Common - Part 2: Geospatial Data` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/collections`
  ///
  /// External dependencies:
  /// * [Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content](https://www.rfc-editor.org/rfc/rfc7231.txt)
  static const common2Collections =
      'http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/collections';

  /// The `Simple Query` conformance class for the
  /// `OGC API - Common - Part 2: Geospatial Data` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/simple-query`
  ///
  /// Dependencies to other conformance classes:
  /// * [common2Collections]
  ///
  /// External dependencies:
  /// * [IETF RFC 3339, Date and Time on the Internet: Timestamps](https://tools.ietf.org/rfc/rfc3339.txt)
  static const common2SimpleQuery =
      'http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/simple-query';

  /// The `JSON` conformance class for the
  /// `OGC API - Common - Part 2: Geospatial Data` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/json`
  ///
  /// Dependencies to other conformance classes:
  /// * [common2Collections]
  ///
  /// External dependencies:
  /// * [IETF RFC 8259, The JavaScript Object Notation (JSON) Data Interchange Format](https://tools.ietf.org/rfc/rfc8259.txt)
  /// * [JSON Schema](https://json-schema.org/specification.html)
  static const common2JSON =
      'http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/json';

  /// The `HTML` conformance class for the
  /// `OGC API - Common - Part 2: Geospatial Data` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/html`
  ///
  /// Dependencies to other conformance classes:
  /// * [common2Collections]
  ///
  /// External dependencies:
  /// * [HTML5](https://www.w3.org/TR/html5/)
  /// * [Schema.org](https://schema.org/docs/schemas.html)
  static const common2HTML =
      'http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/html';
}
