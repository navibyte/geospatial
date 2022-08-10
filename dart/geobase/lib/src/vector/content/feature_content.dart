// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/base.dart';

import 'geometry_content.dart';
import 'property_content.dart';

/// A function to write feature data to [output].
typedef WriteFeatures = void Function(FeatureContent output);

/// An interface to write feature data to format encoders and object builders.
mixin FeatureContent {
  /// Writes a feature collection with a series of [features].
  ///
  /// An optional expected [count], when given, specifies the number of feature
  /// objects in a collection. Note that when given the count MUST be exact.
  ///
  /// An optional [bbox] can used set a minimum bounding box for a feature
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
    Box? bbox,
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
  /// An optional [bbox] can used set a minimum bounding box for a feature
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
    Box? bbox,
    WriteProperties? custom,
  });
}
