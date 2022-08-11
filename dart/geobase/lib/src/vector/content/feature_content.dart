// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/base.dart';

import 'geometry_content.dart';
import 'property_content.dart';

/// A function to write geospatial feature objects to [output].
///
/// Supported feature object types: `Feature` and `FeatureCollection`
typedef WriteFeatures = void Function(FeatureContent output);

/// An interface to write geospatial feature obejcts to format encoders and
/// object builders.
///
/// Supported feature object types: `Feature` and `FeatureCollection`
///
/// According to the [OGC Glossary](https://www.ogc.org/ogc/glossary/f) a
/// feature is "a digital representation of a real world entity. It has a
/// spatial domain, a temporal domain, or a spatial/temporal domain as one of
/// its attributes. Examples of features include almost anything that can be
/// placed in time and space, including desks, buildings, cities, trees, forest
/// stands, ecosystems, delivery vehicles, snow removal routes, oil wells, oil
/// pipelines, oil spill, and so on".
///
/// And a feature collection is "a set of related features managed as a group".
///
/// According to the [GeoJSON](https://geojson.org/) specifiction Feature
/// objects contain a Geometry object and additional members (like "id" and
/// "properties"). A FeatureCollection object contains an array of Feature
/// objects. Both may also contain "bbox" or bounding box. Any other members on
/// Feature and FeatureCollection objects are *foreign members*, allowed
/// property values or geometry objects, but not known by the GeoJSON model.
mixin FeatureContent {
  /// Writes a feature collection with an array of [features].
  ///
  /// An optional expected [count], when given, specifies the number of features
  /// in a collection. Note that when given the count MUST be exact.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a feature
  /// collection written. A writer implementation may use it or ignore it. Known
  /// [Box] sub classes are `ProjBox` (projected or cartesian coordinates) and
  /// `GeoBox` (geographic coordinates). Other sub classes are supported too.
  ///
  /// Use [custom] to write any custom or "foreign member" properties.
  ///
  /// An example:
  /// ```dart
  ///   content.featureCollection(
  ///       count: 2,
  ///       (features) => features
  ///           ..feature(
  ///               id: '1',
  ///               geometry: (geom) => geom.point([10.123, 20.25]),
  ///               properties: {
  ///                  'foo': 100,
  ///                  'bar': 'this is property value',
  ///                  'baz': true,
  ///               },
  ///           )
  ///           ..feature(
  ///               id: '2',
  ///               // ...
  ///           ),
  ///   );
  /// ```
  void featureCollection(
    WriteFeatures features, {
    int? count,
    Box? bounds,
    WriteProperties? custom,
  });

  /// Writes a feature with [id], [geometry] and [properties].
  ///
  /// The [id], when non-null, should be either a string or an integer number.
  ///
  /// At least one geometry using [geometry] should be written using methods
  /// defined by [GeometryContent]. When there are more than one geometry, it's
  /// recommended to use the `name` argument when writing those other.
  ///
  /// An optional [bounds] can used set a minimum bounding box for a feature
  /// written. A writer implementation may use it or ignore it. Known [Box] sub
  /// classes are `ProjBox` (projected or cartesian coordinates) and `GeoBox`
  /// (geographic coordinates). Other sub classes are supported too.
  ///
  /// Use [custom] to write any custom or "foreign member" properties along with
  /// those set by [properties].
  ///
  /// An example:
  /// ```dart
  ///   content.feature(
  ///       id: '1',
  ///       geometry: (geom) => geom.point([10.123, 20.25]),
  ///       properties: {
  ///          'foo': 100,
  ///          'bar': 'this is property value',
  ///          'baz': true,
  ///       },
  ///   );
  /// ```
  void feature({
    Object? id,
    WriteGeometries? geometry,
    Map<String, Object?>? properties,
    Box? bounds,
    WriteProperties? custom,
  });
}
