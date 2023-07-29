// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/ogcapi_common/model/ogc_conformance.dart';

/// A wrapper for conformance classes for a OGC API Features compliant service.
///
/// See [OGC API Features](https://github.com/opengeospatial/ogcapi-features).
///
/// This class can be used to check conformance classes for:
/// * `OGC API - Features - Part 1: Core`
/// * `OGC API - Features - Part 2: Coordinate Reference Systems by Reference`
///
/// The class extends [OGCConformance] that knows also conformance classes for:
/// * `OGC API - Common - Part 1: Core`
/// * `OGC API - Common - Part 2: Geospatial Data`
@immutable
class OGCFeatureConformance extends OGCConformance {
  /// Creates a wrapper for conformance classes a service is conforming to.
  const OGCFeatureConformance(super.classes);

  /// Check whether a service conforms to `OGC API - Features - Part 1: Core`.
  ///
  /// Optionally also check whether it supports [openAPI30], [html], [geoJSON],
  /// [gmlSF0] and/or [gmlSF2].
  ///
  /// Examples:
  /// ```dart
  ///   // Require the `Core` conformance class. Other classes could be
  ///   // supported or not.
  ///   conformsToCore();
  ///
  ///   // Require `Core` and `GeoJSON` conformance classes. Other classes
  ///   // could be supported or not.
  ///   conformsToCore(geoJSON: true);
  ///
  ///   // Require `Core` and `GeoJSON` conformance classes, and require
  ///   // NOT conforming to `HTML`. Other classes could be supported or not.
  ///   conformsToCore(geoJSON: true, html: false);
  /// ```
  bool conformsToFeaturesCore({
    bool? openAPI30,
    bool? html,
    bool? geoJSON,
    bool? gmlSF0,
    bool? gmlSF2,
  }) {
    var isCore = false;
    var isOpenAPI30 = false;
    var isHTML = false;
    var isGeoJSON = false;
    var isGMLSF0 = false;
    var isGMLSF2 = false;

    for (final id in classes) {
      if (!isCore && id == features1Core) {
        isCore = true;
      }
      if (!isOpenAPI30 && id == features1OpenAPI30) {
        isOpenAPI30 = true;
      }
      if (!isHTML && id == features1HTML) {
        isHTML = true;
      }
      if (!isGeoJSON && id == features1GeoJSON) {
        isGeoJSON = true;
      }
      if (!isGMLSF0 && id == features1GMLSF0) {
        isGMLSF0 = true;
      }
      if (!isGMLSF2 && id == features1GMLSF2) {
        isGMLSF2 = true;
      }
    }

    return isCore &&
        (openAPI30 == null || isOpenAPI30 == openAPI30) &&
        (html == null || isHTML == html) &&
        (geoJSON == null || isGeoJSON == geoJSON) &&
        (gmlSF0 == null || isGMLSF0 == gmlSF0) &&
        (gmlSF2 == null || isGMLSF2 == gmlSF2);
  }

  /// Check whether a service conforms to
  /// `OGC API - Features - Part 2: Coordinate Reference Systems by Reference`.
  ///
  /// Examples:
  /// ```dart
  ///   // Require `Coordinate Reference Systems by Reference` conformance
  ///   // class. Other classes could be supported or not.
  ///   conformsToCrs();
  /// ```
  bool conformsToFeaturesCrs() => classes.contains(features2Crs);

  /// The `Core` conformance class for the
  /// `OGC API - Features - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/core`
  ///
  /// External dependencies:
  /// * [RFC 9110 (HTTP Semantics)](https://www.rfc-editor.org/rfc/rfc9110.html)
  /// * [RFC 9112 (HTTP/1.1)](https://www.rfc-editor.org/rfc/rfc9112.html)
  /// * [RFC 2818 (HTTP over TLS)](https://www.rfc-editor.org/rfc/rfc2818.html)
  /// * [RFC 3339 (Date and Time on the Internet: Timestamps)](https://www.rfc-editor.org/rfc/rfc3339.html)
  /// * [RFC 8288 (Web Linking)](https://www.rfc-editor.org/rfc/rfc8288.html)
  static const features1Core =
      'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/core';

  /// The `OpenAPI 3.0` conformance class for the
  /// `OGC API - Features - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/oas30`
  ///
  /// Dependencies to other conformance classes:
  /// * [features1Core]
  ///
  /// External dependencies:
  /// * [OpenAPI Specification 3.0](https://github.com/OAI/OpenAPI-Specification/)
  static const features1OpenAPI30 =
      'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/oas30';

  /// The `HTML` conformance class for the
  /// `OGC API - Features - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/html`
  ///
  /// Dependencies to other conformance classes:
  /// * [features1Core]
  ///
  /// External dependencies:
  /// * [HTML5](https://html.spec.whatwg.org/)
  /// * [Schema.org](https://schema.org/docs/schemas.html)
  static const features1HTML =
      'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/html';

  /// The `GeoJSON` conformance class for the
  /// `OGC API - Features - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/geojson`
  ///
  /// Dependencies to other conformance classes:
  /// * [features1Core]
  ///
  /// External dependencies:
  /// * [GeoJSON](https://www.rfc-editor.org/rfc/rfc7946.html)
  static const features1GeoJSON =
      'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/geojson';

  /// The `GML Simple Features Level 0` conformance class for
  /// the `OGC API - Features - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/gmlsf0`
  ///
  /// Dependencies to other conformance classes:
  /// * [features1Core]
  ///
  /// External dependencies:
  /// * [Geography Markup Language (GML) Simple Features Profile, Level 0](https://portal.opengeospatial.org/files/?artifact_id=42729)
  static const features1GMLSF0 =
      'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/gmlsf0';

  /// The `GML Simple Features Level 2` conformance class for
  /// the `OGC API - Features - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/gmlsf2`
  ///
  /// Dependencies to other conformance classes:
  /// * [features1Core]
  ///
  /// External dependencies:
  /// * [Geography Markup Language (GML) Simple Features Profile, Level 2](https://portal.opengeospatial.org/files/?artifact_id=42729)
  static const features1GMLSF2 =
      'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/gmlsf2';

  /// The `Coordinate Reference Systems by Reference` conformance class for
  /// the
  /// `OGC API - Features - Part 2: Coordinate Reference Systems by Reference`
  /// standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-2/1.0/conf/crs`
  ///
  /// Dependencies to other conformance classes:
  /// * [features1Core]
  static const features2Crs =
      'http://www.opengis.net/spec/ogcapi-features-2/1.0/conf/crs';
}
