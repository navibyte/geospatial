// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/codes/geom.dart';
import '/src/coordinates/projection.dart';
import '/src/vector/content.dart';
import '/src/vector/encoding.dart';
import '/src/vector/formats.dart';
import '/src/vector_data/model/bounded.dart';

/// A base interface for geometry classes.
@immutable
abstract class Geometry extends Bounded {
  /// A geometry with an optional [bounds].
  const Geometry({super.bounds});

  /// The geometry type.
  Geom get geomType;

  /// Returns a new geometry projected using [projection].
  ///
  /// The returned geometry sub type must be the same as the type of this.
  ///
  /// Note that any available [bounds] object on this is not projected (that is
  /// the bounds for a returned geometry is null).
  @override
  Geometry project(Projection projection);

  /// Writes this geometry object to [writer].
  ///
  /// Use an optional [name] to specify a name for a geometry (when applicable).
  void writeTo(GeometryContent writer, {String? name});

  /// The string representation of this geometry object, with [format] applied.
  ///
  /// When [format] is not given, then [GeoJSON] is used as a default.
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  String toText({
    TextWriterFormat<GeometryContent> format = GeoJSON.geometry,
    int? decimals,
  }) {
    final encoder = format.encoder(decimals: decimals);
    writeTo(encoder.writer);
    return encoder.toText();
  }

  /// The string representation of this geometry object as specified by
  /// [GeoJSON].
  ///
  /// See also [toText].
  @override
  String toString() => toText();
}

/// A base interface for "simple" geometry classes.
abstract class SimpleGeometry extends Geometry {
  /// A "simple" geometry with an optional [bounds].
  const SimpleGeometry({super.bounds});

  /// The coordinate type for this geometry.
  Coords get coordType;

  @override
  void writeTo(SimpleGeometryContent writer, {String? name});

  @override
  String toText({
    TextWriterFormat<SimpleGeometryContent> format = GeoJSON.geometry,
    int? decimals,
  }) {
    final encoder = format.encoder(decimals: decimals);
    writeTo(encoder.writer);
    return encoder.toText();
  }
}
