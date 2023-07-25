// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A wrapper for conformance classes for a OGC API Common compliant service.
///
/// See [OGC API Common](https://github.com/opengeospatial/ogcapi-common).
@immutable
class OGCConformance extends Equatable {
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
      if (!isCore && id == common1CoreClass) {
        isCore = true;
      }
      if (!isLandingPage && id == common1LandingPageClass) {
        isLandingPage = true;
      }
      if (!isHTML && id == common1HTMLClass) {
        isHTML = true;
      }
      if (!isJSON && id == common1JSONClass) {
        isJSON = true;
      }
      if (!isOpenAPI30 && id == common1OpenAPI30Class) {
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
      if (!isCollections && id == common2CollectionsClass) {
        isCollections = true;
      }
      if (!isSimpleQuery && id == common2SimpleQueryClass) {
        isSimpleQuery = true;
      }
      if (!isHTML && id == common2HTMLClass) {
        isHTML = true;
      }
      if (!isJSON && id == common2JSONClass) {
        isJSON = true;
      }
    }

    return isCollections &&
        (simpleQuery == null || isSimpleQuery == simpleQuery) &&
        (json == null || isJSON == json) &&
        (html == null || isHTML == html);
  }

  @override
  List<Object?> get props => [classes];

  /// The `Core` conformance class for the
  /// `OGC API - Common - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/core`
  static const common1CoreClass =
      'http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/core';

  /// The `Landing Page` conformance class for the
  /// `OGC API - Common - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/landing-page`
  ///
  /// Prerequisites:
  /// * [common1CoreClass]
  static const common1LandingPageClass =
      'http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/landing-page';

  /// The `JSON` conformance class for the
  /// `OGC API - Common - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/json`
  ///
  /// Prerequisites:
  /// * [common1CoreClass]
  /// * [common1LandingPageClass]
  static const common1JSONClass =
      'http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/json';

  /// The `HTML` conformance class for the
  /// `OGC API - Common - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/html`.
  ///
  /// Prerequisites:
  /// * [common1CoreClass]
  /// * [common1LandingPageClass]
  static const common1HTMLClass =
      'http://www.opengis.net/spec/ogcapi-common-1/1.0/conf/html';

  /// The `OpenAPI 3.0` conformance class for the
  /// `OGC API - Common - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common/1.0/req/oas30`.
  ///
  /// Prerequisites:
  /// * [common1CoreClass]
  /// * [common1LandingPageClass]
  static const common1OpenAPI30Class =
      'http://www.opengis.net/spec/ogcapi-common/1.0/req/oas30';

  /// The `Collections` conformance class for the
  /// `OGC API - Common - Part 2: Geospatial Data` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/collections`
  static const common2CollectionsClass =
      'http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/collections';

  /// The `Simple Query` conformance class for the
  /// `OGC API - Common - Part 2: Geospatial Data` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/simple-query`
  ///
  /// Prerequisites:
  /// * [common2CollectionsClass]
  static const common2SimpleQueryClass =
      'http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/simple-query';

  /// The `JSON` conformance class for the
  /// `OGC API - Common - Part 2: Geospatial Data` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/json`
  ///
  /// Prerequisites:
  /// * [common2CollectionsClass]
  static const common2JSONClass =
      'http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/json';

  /// The `HTML` conformance class for the
  /// `OGC API - Common - Part 2: Geospatial Data` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/html`
  ///
  /// Prerequisites:
  /// * [common2CollectionsClass]
  static const common2HTMLClass =
      'http://www.opengis.net/spec/ogcapi-common-2/1.0/conf/html';
}
