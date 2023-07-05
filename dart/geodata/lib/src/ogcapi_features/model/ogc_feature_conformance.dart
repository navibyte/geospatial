// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A wrapper for conformance classes for a OGC API Features compliant service.
///
/// See [OGC API Features](https://github.com/opengeospatial/ogcapi-features).
///
/// This class can be used to check conformance classes for:
/// * `OGC API - Features - Part 1: Core`
/// * `OGC API - Features - Part 2: Coordinate Reference Systems by Reference`
@immutable
class OGCFeatureConformance extends Equatable {
  /// Conformance classes a service is conforming to.
  final Iterable<String> classes;

  /// Creates a wrapper for conformance classes a service is conforming to.
  const OGCFeatureConformance(this.classes);

  /// Check whether a service conforms to `OGC API - Features - Part 1: Core`.
  ///
  /// Optionally also check whether it supports [openAPI30Class],
  /// [htmlClass], [geoJSONClass], [gmlSF0] and/or [gmlSF2].
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
  bool conformsToCore({
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
      if (!isCore && id == coreClass) {
        isCore = true;
      }
      if (!isOpenAPI30 && id == openAPI30Class) {
        isOpenAPI30 = true;
      }
      if (!isHTML && id == htmlClass) {
        isHTML = true;
      }
      if (!isGeoJSON && id == geoJSONClass) {
        isGeoJSON = true;
      }
      if (!isGMLSF0 && id == gmlSF0Class) {
        isGMLSF0 = true;
      }
      if (!isGMLSF2 && id == gmlSF2Class) {
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
  bool conformsToCrs() => classes.contains(crsClass);

  @override
  List<Object?> get props => [classes];

  /// The `Core` conformance class for the
  /// `OGC API - Features - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/core`
  static const coreClass =
      'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/core';

  /// The `OpenAPI 3.0` conformance class for the
  /// `OGC API - Features - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/oas30`.
  static const openAPI30Class =
      'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/oas30';

  /// The `HTML` conformance class for the
  /// `OGC API - Features - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/html`.
  static const htmlClass =
      'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/html';

  /// The `GeoJSON` conformance class for the
  /// `OGC API - Features - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/geojson`.
  static const geoJSONClass =
      'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/geojson';

  /// The `GML Simple Features Level 0` conformance class for
  /// the `OGC API - Features - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/gmlsf0`.
  static const gmlSF0Class =
      'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/gmlsf0';

  /// The `GML Simple Features Level 2` conformance class for
  /// the `OGC API - Features - Part 1: Core` standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/gmlsf2`.
  static const gmlSF2Class =
      'http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/gmlsf2';

  /// The `Coordinate Reference Systems by Reference` conformance class for
  /// the
  /// `OGC API - Features - Part 2: Coordinate Reference Systems by Reference`
  /// standard.
  ///
  /// `http://www.opengis.net/spec/ogcapi-features-2/1.0/conf/crs`.
  static const crsClass =
      'http://www.opengis.net/spec/ogcapi-features-2/1.0/conf/crs';
}
