// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// WGS84 based projections; ellipsoidal (geographic, geocentric, UTM) and
/// spherical (Web Mercator).
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// See also `package:geobase/projections_proj4d.dart` that provides a
/// projection adapter using the external `proj4dart` package.
///
/// Usage: import `package:geobase/projections.dart`
///
/// Examples:
///
/// ```dart
///   // Projections can be applied on any geometry and feature objects along with
///   // positions.
///
///   // The source point geometry with a position in WGS 84 coordinates.
///   final positionWgs84 = Geographic(lon: 2.2945, lat: 48.8582);
///   final point = Point(positionWgs84);
///
///   // Project to UTM projected coordinates (in zone 31 N).
///   final zone31N = UtmZone(31, 'N');
///   final wgs84toUtm31N = WGS84.utmZone(zone31N).forward;
///   final pointUtm31N = point.project(wgs84toUtm31N);
///
///   // Project back to WGS 84 coordinates.
///   final utm31NtoWgs84 = WGS84.utmZone(zone31N).inverse;
///   final pointWgs84 = pointUtm31N.project(utm31NtoWgs84);
///
///   // Print the original and projected point coordinates.
///   //    {"type":"Point","coordinates":[2.2945,48.8582]} =>
///   //    {"type":"Point","coordinates":[448251.80,5411932.68]} =>
///   //    {"type":"Point","coordinates":[2.2945,48.8582]}"
///   print('${point.toText(decimals: 4)} => ${pointUtm31N.toText(decimals: 2)}'
///       ' => ${pointWgs84.toText(decimals: 4)}');
///
///   // Project between WGS84 based UTM zones. Note that resulting coordinates may
///   // have strange values if the point do not locate inside the target zone.
///   final zone30N = UtmZone(30, 'N');
///   final utm31NtoUtm30N = WGS84.utmZoneToZone(zone31N, zone30N).forward;
///   final pointUtm30N = pointUtm31N.project(utm31NtoUtm30N);
///   print(pointUtm30N.position.toText(decimals: 2)); // 888276.96,5425220.84
///
///   // It's always possible to check the UTM zone a point is located in.
///   final zone = UtmZone.fromGeographic(positionWgs84);
///   print(zone); // 31 N
///
///   // The source WGS84 geographic position to geocentric cartesian.
///   final wgs84toGeocentric = WGS84.geocentric.forward;
///   final pointGeocentric = point.project(wgs84toGeocentric);
///   // prints "4200952.55,168323.77,4780198.41"
///   print(pointGeocentric.position.toText(decimals: 2));
///
///   // The source WGS84 geographic position to WG84 web mercator (metric).
///   final wgs84toWebMercator = WGS84.webMercator.forward;
///   final pointWebMercator = point.project(wgs84toWebMercator);
///   print(pointWebMercator.position.toText(decimals: 2)); // 255422.57,6250835.06
///
///   // Other datum, for example from WGS 84 geographic to ED50 geographic.
///   // In this sample `project` is called directly on the position, not on the
///   // point geometry object (that is possible too).
///   final wgs84toED50Adapter = WGS84.geographicToDatum(
///     const CoordRefSys.id('http://www.opengis.net/def/crs/EPSG/0/4230'),
///     Datum.ED50,
///   );
///   final positionED50 = positionWgs84.project(wgs84toED50Adapter.forward);
///   // prints : "2.2945,48.8582 => 2.2958,48.8591"
///   print('${positionWgs84.toText(decimals: 4)} => '
///      '${positionED50.toText(decimals: 4)}');
/// ```
library projections;

export 'src/common/reference/coord_ref_sys.dart';
export 'src/geodesy/ellipsoidal/datum.dart' show Datum;
export 'src/geodesy/ellipsoidal/utm.dart' show UtmZone;
export 'src/projections/wgs84/wgs84.dart';
