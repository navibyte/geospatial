// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '/src/aspects/codes.dart';
import '/src/aspects/encode.dart';
import '/src/aspects/format.dart';
import '/src/base/spatial.dart';
import '/src/utils/wkt_data.dart';

import 'linestring.dart';

/// A polygon with an exterior and optional interior boundaries.
@immutable
class Polygon<T extends Point> extends Geometry
    with EquatableMixin, GeometryWritableMixin {
  // note : mixins must be on that order (need toString from the latter)

  /// Create [Polygon] from [rings] with at least exterior boundary at index 0.
  ///
  /// Contains also interior boundaries if length is >= 2.
  ///
  /// A polygon is considered empty if the exterior is empty.
  Polygon(Iterable<LineString<T>> rings) : rings = validate<T>(rings);

  /// Create [Polygon] from [rings] with at least exterior boundary at index 0.
  ///
  /// Contains also interior boundaries if length is >= 2.
  ///
  /// Boundaries in [rings] are represented as iterables of points of [T].
  Polygon.fromPoints(
    Iterable<Iterable<T>> rings,
  ) : this(
          BoundedSeries.from(
            rings.map(
              (ring) => LineString.ring(
                ring is PointSeries<T> ? ring : PointSeries.view(ring),
              ),
            ),
          ),
        );

  /// Create [Polygon] from [values] with a list of rings.
  ///
  /// An optional [bounds] can be provided or it's lazy calculated if null.
  factory Polygon.make(
    Iterable<Iterable<Iterable<num>>> values,
    PointFactory<T> pointFactory, {
    Bounds? bounds,
  }) =>
      Polygon<T>(
        BoundedSeries.from(
          values.map<LineString<T>>(
            (pointSeries) => LineString<T>.make(
              pointSeries,
              pointFactory,
              type: LineStringType.ring,
            ),
          ),
          bounds: bounds,
        ),
      );

  /// Create [Polygon] parsed from [text] with a list of rings.
  ///
  /// If [parser] is null, then WKT [text] like
  /// "(40 15, 50 50, 15 45, 10 15, 40 15), (25 25, 25 40, 35 30, 25 25)"
  /// is expected.
  ///
  /// Throws FormatException if cannot parse.
  factory Polygon.parse(
    String text,
    PointFactory<T> pointFactory, {
    ParseCoordsListList? parser,
  }) =>
      parser != null
          ? Polygon<T>.make(parser.call(text), pointFactory)
          : parseWktPolygon<T>(text, pointFactory);

  /// Validate [rings] to have at least one exterior and all must be rings.
  static BoundedSeries<LineString<T>> validate<T extends Point>(
    Iterable<LineString<T>> rings,
  ) {
    if (rings.isEmpty) {
      throw ArgumentError('Polygon must have exterior ring.');
    }
    for (final ring in rings) {
      if (ring.type != LineStringType.ring) {
        throw ArgumentError('Not a linear ring.');
      }
    }
    return rings is BoundedSeries<LineString<T>>
        ? rings
        : BoundedSeries.view(rings);
  }

  /// Linear rings with at least exterior boundary at index 0.
  ///
  /// Contains also interior boundaries if length is >= 2.
  final BoundedSeries<LineString<T>> rings;

  @override
  List<Object?> get props => [rings];

  @override
  int get dimension => 2;

  @override
  bool get isEmpty => exterior.isEmpty;

  @override
  Bounds get bounds => exterior.bounds;

  @override
  Point? get onePoint {
    final chain = exterior.chain;
    return chain.isNotEmpty ? chain.first : null;
  }

  /// A linear ring forming an [exterior] boundary for this polygon.
  LineString<T> get exterior => rings.first;

  /// A series of interior rings (holes for this polygon) with 0 to N elements.
  BoundedSeries<LineString<T>> get interior =>
      BoundedSeries<LineString<T>>.view(rings.skip(1));

  @override
  void writeTo(GeometryWriter writer) {
    final point = onePoint;
    writer
      ..geometry(Geom.polygon, expectedType: point?.type)
      ..coordArray(expectedCount: rings.length);
    for (final ring in rings) {
      ring.writeTo(writer);
    }
    writer
      ..coordArrayEnd()
      ..geometryEnd();
  }

  @override
  Polygon<T> transform(TransformPoint transform) =>
      Polygon(rings.transform(transform, lazy: false));

  @override
  Polygon<R> project<R extends Point>(
    Projection<R> projection, {
    PointFactory<R>? to,
  }) =>
      Polygon<R>(
        rings.convert((ring) => ring.project(projection, to: to)),
      );
}
