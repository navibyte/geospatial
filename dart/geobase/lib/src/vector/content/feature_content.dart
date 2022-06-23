// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/base.dart';
import '/src/coordinates/geographic.dart';
import '/src/coordinates/projected.dart';

import 'geometry_content.dart';
import 'property_content.dart';

/// A function that is capable of writing features to [output].
typedef WriteFeatures = void Function(FeatureContent output);

/// An interface to write features to a geospatial content receiver.
/// 
/// A receiver could be a geospatial data format writer or an object factory.
mixin FeatureContent  {
  /// Writes a feature collection represented by [features].
  ///
  /// An optional expected [count], when given, hints the count of features.
  ///
  /// An optional [bbox] can used set a minimum bounding box for a feature
  /// collection written. A writer implementation may use it or ignore it.
  ///
  /// Use [extra] to write any extra or "foreign member" properties.
  ///
  /// Known [Box] sub classes are [ProjBox] (projected or cartesian coordinates)
  /// and [GeoBox] (geographic coordinates).
  ///
  /// An example:
  /// ```dart
  ///   content.featureCollection(
  ///       count: 2,
  ///       features: (feat) => feat
  ///           ..feature(
  ///               id: '1',
  ///               geometries: (geom) => geom.geometry(
  ///                  type: Geom.point,
  ///                  coordinates: const Position(x: 10.123, y: 20.25),
  ///               ),
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
  void featureCollection({
    required WriteFeatures features,
    int? count,
    Box? bbox,
    WriteProperties? extra,
  });

  /// Writes a feature represented by [id], [geometries] and [properties].
  ///
  /// The [id], when non-null, should be either a string or an integer number.
  ///
  /// At least one geometry using [geometries] should be written using methods
  /// defined by [GeometryContent]. When there are more than one geometry, it's
  /// recommended to use the `name` argument when writing those.
  ///
  /// An optional [bbox] can used set a minimum bounding box for a feature
  /// written. A writer implementation may use it or ignore it.
  ///
  /// Use [extra] to write any extra or "foreign member" properties along with
  /// those set by [properties].
  ///
  /// Known [Box] sub classes are [ProjBox] (projected or cartesian coordinates)
  /// and [GeoBox] (geographic coordinates).
  ///
  /// An example:
  /// ```dart
  ///   content.feature(
  ///       id: '1',
  ///       geometries: (geom) => geom.geometry(
  ///          type: Geom.point,
  ///          coordinates: const Position(x: 10.123, y: 20.25),
  ///       ),
  ///       properties: {
  ///          'foo': 100,
  ///          'bar': 'this is property value',
  ///          'baz': true,
  ///       },
  ///   );
  /// ```
  void feature({
    Object? id,
    WriteGeometries? geometries,
    Map<String, Object?>? properties,
    Box? bbox,
    WriteProperties? extra,
  });
}
