// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/base/spatial.dart';
import '/src/utils/wkt.dart';

import 'geopoint.dart';
import 'geopoint_immutable.dart';

/// An immutable geographic bounds with min and max points for limits.
///
/// Geographic bounds can be represented as Bounds<GeoPoint> or as GeoBounds.
/// This is a convenience class with helper factory constructors.
class GeoBounds<T extends GeoPoint> extends BoundsBase<T> {
  /// Create geographic bounds by copying `min` and `max` points from [source].
  GeoBounds(Bounds<T> source) : super(min: source.min, max: source.max);

  /// Create geographic bounds with required [min] and [max] points.
  ///
  /// [min] and [max] objects set on the bounds may or may not to be immutable.
  const GeoBounds.of({
    required T min,
    required T max,
  }) : super(min: min, max: max);

  /// Geographic bounds from [values] with two points (both a list of nums).
  factory GeoBounds.make(
    Iterable<Iterable<num>> values,
    PointFactory<T> pointFactory,
  ) =>
      GeoBounds<T>.of(
        min: pointFactory.newFrom(values.elementAt(0)),
        max: pointFactory.newFrom(values.elementAt(1)),
      );

  /// Geographic bounds parsed from [text] with two points.
  ///
  /// If [parser] is null, then WKT [text] like "25.1 53.1, 25.2 53.2" is
  /// expected.
  factory GeoBounds.parse(
    String text,
    PointFactory<T> pointFactory, {
    ParseCoordsList? parser,
  }) {
    if (parser != null) {
      final coordsList = parser.call(text);
      return GeoBounds<T>.make(coordsList, pointFactory);
    } else {
      final points = parseWktPointSeries(text, pointFactory);
      return GeoBounds<T>.of(min: points[0], max: points[1]);
    }
  }

  /// World bounds (longitude: -180.0 to 180.0, latitude: -90.0 to 90.0).
  static GeoBounds<GeoPoint2> world() => const GeoBounds<GeoPoint2>.of(
        min: GeoPoint2.lonLat(-180.0, -90.0),
        max: GeoPoint2.lonLat(180.0, 90.0),
      );

  /// With minimum and maximum pairs of longitude and latitude (+optional elev).
  static GeoBounds<GeoPoint2> bbox({
    required double minLon,
    required double minLat,
    double? minElev,
    required double maxLon,
    required double maxLat,
    double? maxElev,
  }) =>
      GeoBounds<GeoPoint2>.of(
        min: minElev != null
            ? GeoPoint3.lonLatElev(minLon, minLat, minElev)
            : GeoPoint2.lonLat(minLon, minLat),
        max: maxElev != null
            ? GeoPoint3.lonLatElev(maxLon, maxLat, maxElev)
            : GeoPoint2.lonLat(maxLon, maxLat),
      );

  /// With minimum and maximum pairs of longitude and latitude.
  static GeoBounds<GeoPoint2> bboxLonLat(
    double minLon,
    double minLat,
    double maxLon,
    double maxLat,
  ) =>
      GeoBounds<GeoPoint2>.of(
        min: GeoPoint2.lonLat(minLon, minLat),
        max: GeoPoint2.lonLat(maxLon, maxLat),
      );

  /// With minimum and maximum sets of longitude, latitude and elevation.
  static GeoBounds<GeoPoint3> bboxLonLatElev(
    double minLon,
    double minLat,
    double minElev,
    double maxLon,
    double maxLat,
    double maxElev,
  ) =>
      GeoBounds<GeoPoint3>.of(
        min: GeoPoint3.lonLatElev(minLon, minLat, minElev),
        max: GeoPoint3.lonLatElev(maxLon, maxLat, maxElev),
      );

  /// With minimum and maximum pairs of latitude and longitude.
  static GeoBounds<GeoPoint2> bboxLatLon(
    double minLat,
    double minLon,
    double maxLat,
    double maxLon,
  ) =>
      GeoBounds<GeoPoint2>.of(
        min: GeoPoint2.latLon(minLat, minLon),
        max: GeoPoint2.latLon(maxLat, maxLon),
      );

  /// With [coords] containing min and max sets of lon, lat and optional elev.
  ///
  /// There should be either 4 or 6 items on [coords].
  static GeoBounds from(
    Iterable<num> coords, {
    int? offset,
    int? length,
  }) {
    CoordinateFactory.checkCoords(4, coords, offset: offset, length: length);
    final start = offset ?? 0;
    final len = length ?? coords.length;
    return len >= 6
        ? GeoBounds.bboxLonLatElev(
            coords.elementAt(start + 0).toDouble(),
            coords.elementAt(start + 1).toDouble(),
            coords.elementAt(start + 2).toDouble(),
            coords.elementAt(start + 3).toDouble(),
            coords.elementAt(start + 4).toDouble(),
            coords.elementAt(start + 5).toDouble(),
          )
        : GeoBounds.bboxLonLat(
            coords.elementAt(start + 0).toDouble(),
            coords.elementAt(start + 1).toDouble(),
            coords.elementAt(start + 2).toDouble(),
            coords.elementAt(start + 3).toDouble(),
          );
  }

  /// Create geographic bounds from [coords] using [pointFactory].
  static GeoBounds<R> fromCoords<R extends GeoPoint>(
    Iterable<num> coords, {
    required PointFactory<R> pointFactory,
    int? offset,
    int? length,
  }) {
    CoordinateFactory.checkCoords(4, coords, offset: offset, length: length);
    final start = offset ?? 0;
    final len = length ?? coords.length;
    final pointLen = len ~/ 2;
    return GeoBounds<R>.of(
      min: pointFactory.newFrom(
        coords,
        offset: start,
        length: pointLen,
      ),
      max: pointFactory.newFrom(
        coords,
        offset: start + pointLen,
        length: pointLen,
      ),
    );
  }

  @override
  GeoBounds<T> newFrom(Iterable<num> coords, {int? offset, int? length}) {
    CoordinateFactory.checkCoords(4, coords, offset: offset, length: length);
    final start = offset ?? 0;
    final len = length ?? coords.length;
    final pointLen = len ~/ 2;
    return GeoBounds<T>.of(
      min: min.newFrom(
        coords,
        offset: start,
        length: pointLen,
      ) as T,
      max: max.newFrom(
        coords,
        offset: start + pointLen,
        length: pointLen,
      ) as T,
    );
  }

  @override
  GeoBounds<T> transform(TransformPoint transform) => GeoBounds.of(
        min: min.transform(transform) as T,
        max: max.transform(transform) as T,
      );

  @override
  bool get isGeographic => true;
}
