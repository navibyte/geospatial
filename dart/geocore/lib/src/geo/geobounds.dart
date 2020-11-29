// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import '../base/bounds.dart';
import '../utils/parse/values.dart';

import 'geopoint.dart';

/// An immutable geographic bounds with min and max points for limits.
@immutable
class GeoBounds extends Bounds<GeoPoint> with EquatableMixin {
  /// With required [min] and [max] points.
  ///
  /// [min] and [max] objects set on the bounds may or may not to be immutable.
  const GeoBounds({
    required GeoPoint min,
    required GeoPoint max,
  })   : _min = min,
        _max = max;

  /// With minimum and maximum pairs of longitude and latitude (+optional elev).
  GeoBounds.bbox(
      {required double minLon,
      required double minLat,
      double? minElev,
      required double maxLon,
      required double maxLat,
      double? maxElev})
      : this(
            min: minElev != null
                ? GeoPoint3.lonLatElev(minLon, minLat, minElev)
                : GeoPoint2.lonLat(minLon, minLat),
            max: maxElev != null
                ? GeoPoint3.lonLatElev(maxLon, maxLat, maxElev)
                : GeoPoint2.lonLat(maxLon, maxLat));

  /// With minimum and maximum pairs of longitude and latitude.
  GeoBounds.bboxLonLat(
      double minLon, double minLat, double maxLon, double maxLat)
      : this(
            min: GeoPoint2.lonLat(minLon, minLat),
            max: GeoPoint2.lonLat(maxLon, maxLat));

  /// With minimum and maximum sets of longitude, latitude and elevation.
  GeoBounds.bboxLonLatElev(double minLon, double minLat, double minElev,
      double maxLon, double maxLat, double maxElev)
      : this(
            min: GeoPoint3.lonLatElev(minLon, minLat, minElev),
            max: GeoPoint3.lonLatElev(maxLon, maxLat, maxElev));

  /// With minimum and maximum pairs of latitude and longitude.
  GeoBounds.bboxLatLon(
      double minLat, double minLon, double maxLat, double maxLon)
      : this(
            min: GeoPoint2.latLon(minLat, minLon),
            max: GeoPoint2.latLon(maxLat, maxLon));

  /// Geographical bounds from the list of [coords] (length must be 4 or 6).
  ///
  /// For length 4: minLon, minLat, maxLon, maxLat.
  ///
  /// For length 6: minLon, minLat, minElev, maxLon, maxLat, maxElev.
  ///
  /// List elements are converted to doubles using [valueToDouble] function.
  ///
  /// For other lengths an ArgumentError is thrown.
  factory GeoBounds.from(List<dynamic> coords) {
    if (coords.length == 4) {
      return GeoBounds.bboxLonLat(
        valueToDouble(coords[0]),
        valueToDouble(coords[1]),
        valueToDouble(coords[2]),
        valueToDouble(coords[3]),
      );
    } else if (coords.length == 6) {
      return GeoBounds.bboxLonLatElev(
        valueToDouble(coords[0]),
        valueToDouble(coords[1]),
        valueToDouble(coords[2]),
        valueToDouble(coords[3]),
        valueToDouble(coords[4]),
        valueToDouble(coords[5]),
      );
    }
    throw ArgumentError.value(coords, '');
  }

  final GeoPoint _min, _max;

  @override
  List<Object?> get props => [_min, _max];

  @override
  int get coordinateDimension => _min.coordinateDimension;

  @override
  int get spatialDimension => _min.spatialDimension;

  @override
  GeoPoint get min => _min;

  @override
  GeoPoint get max => _max;
}
