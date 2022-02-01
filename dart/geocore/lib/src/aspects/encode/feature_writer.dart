// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'base_writer.dart';
import 'bounds_writer.dart';
import 'geometry_writer.dart';
import 'property_writer.dart';

/// A function that is capable of writing features to [writer].
typedef WriteFeatures = void Function(FeatureWriter writer);

/// An interface to write features into some content format.
abstract class FeatureWriter extends BaseWriter {
  /// Writes a feature collection with [features].
  ///
  /// An optional expected [count], when given, hints the count of features.
  ///
  /// An optional [bounds] function can be used to write feature collection
  /// bounds. A writer implementation may use it or ignore it.
  ///
  /// Use [extra] to write any extra or "foreign member" properties.
  ///
  /// An example:
  /// ```dart
  ///   writer.featureCollection(
  ///       count: 2,
  ///       features: (fw) => fw
  ///           ..feature(
  ///               id: '1',
  ///               geometry: (gw) => gw.geometry(
  ///                  type: Geom.point,
  ///                  coordinates: (cw) => cw.coordPoint(x: 10.123, y: 20.25),
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
    WriteBounds? bounds,
    WriteProperties? extra,
  });

  /// Writes a feature with [id], [geometries] and [properties].
  /// 
  /// The [id], when non-null, should be either a string or an integer number.
  ///
  /// At least one geometry using [geometries] should be written using methods
  /// defined by [GeometryWriter]. When there are more than one geometry, it's
  /// recommended to use the `name` argument when writing those.
  ///
  /// An optional [bounds] function can be used to write feature
  /// bounds. A writer implementation may use it or ignore it.
  ///
  /// Use [extra] to write any extra or "foreign member" properties along with
  /// those set by [properties].
  ///
  /// An example:
  /// ```dart
  ///   writer.feature(
  ///       id: '1',
  ///       geometries: (gw) => gw.geometry(
  ///          type: Geom.point,
  ///          coordinates: (cw) => cw.coordPoint(x: 10.123, y: 20.25),
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
    WriteBounds? bounds,
    WriteProperties? extra,
  });
}
