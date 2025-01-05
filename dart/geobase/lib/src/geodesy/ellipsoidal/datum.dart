/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Geodesy tools for conversions between (historical) datums          (c) Chris Veness 2005-2022  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/latlong-convert-coords.html                                     */
/* www.movable-type.co.uk/scripts/geodesy-library.html#latlon-ellipsoidal-datum                  */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

/* sources:
 * - ED50:       www.gov.uk/guidance/oil-and-gas-petroleum-operations-notices#pon-4
 * - Irl1975:    www.osi.ie/wp-content/uploads/2015/05/transformations_booklet.pdf
 * - NAD27:      en.wikipedia.org/wiki/Helmert_transformation
 * - NAD83:      www.uvm.edu/giv/resources/WGS84_NAD83.pdf [strictly, WGS84(G1150) -> NAD83(CORS96) @ epoch 1997.0]
 *               (note NAD83(1986) ≡ WGS84(Original); confluence.qps.nl/pages/viewpage.action?pageId=29855173)
 * - NTF:        Nouvelle Triangulation Francaise geodesie.ign.fr/contenu/fichiers/Changement_systeme_geodesique.pdf
 * - OSGB36:     www.ordnancesurvey.co.uk/docs/support/guide-coordinate-systems-great-britain.pdf
 * - Potsdam:    kartoweb.itc.nl/geometrics/Coordinate%20transformations/coordtrans.html
 * - TokyoJapan: www.geocachingtoolbox.com?page=datumEllipsoidDetails
 * - WGS72:      www.icao.int/safety/pbn/documentation/eurocontrol/eurocontrol wgs 84 implementation manual.pdf
 *
 * more transform parameters are available from earth-info.nga.mil/GandG/coordsys/datums/NATO_DT.pdf,
 * www.fieldenmaps.info/cconv/web/cconv_params.js
 */

// Geodesy tools for conversions between (historical) datums (see license above)
// by Chris Veness ported to Dart by Navibyte.
//
// Source:
// https://github.com/chrisveness/geodesy/blob/master/lanlon-ellipsoidal-datum.js

// Adaptations on the derivative work (the Dart port):
//
// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: lines_longer_than_80_chars, constant_identifier_names

import 'package:meta/meta.dart';

import '/src/common/functions/position_functions.dart';
import '/src/common/reference/ellipsoid.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/geographic/geographic.dart';
import '/src/utils/object_utils.dart';

import 'ellipsoidal.dart';

/// A geodetic datum with a reference ellipsoid and datum transformation
/// parameters.
///
/// This class also contains definitions (as static constants) for some
/// historical geodetic datums: a latitude/longitude point defines a geographic
/// location on or above/below the  earth’s surface, measured in degrees from
/// the equator & the International Reference Meridian and metres above the
/// ellipsoid, and based on a given datum. The datum is based on a reference
/// ellipsoid and tied to geodetic survey reference points.
///
/// Modern geodesy is generally based on the WGS84 datum (as used for instance
/// by GPS systems), but previously various reference ellipsoids and datum
/// references were used.
///
/// This class provides references to ellipsoid parameters and datum
/// transformation parameters, and methods for converting between different
/// (generally historical) datums.
///
/// The datum transformation parameters are Helmert 7-parameter transformations.
///
/// Ellipsoids of historical datums are defined as static constants in the
/// [HistoricalEllipsoids] class.
@immutable
class Datum {
  /// The reference ellipsoid for the datum.
  final Ellipsoid ellipsoid;

  /// The datum transformation parameters to transform coordinates.
  ///
  /// A tranform list contains exactly seven parameters:
  /// `[tx, ty, tz, s, rx, ry, rz]`.
  ///
  /// Units of parameters: `t` in metres, `s` in ppm, `r` in arcseconds.
  final List<double> transform;

  /// Create a geodesic datum with a reference [ellipsoid] and datum
  /// parameters to [transform] coordinates.
  ///
  /// The [transform] list MUST contain exactly seven parameters:
  /// `[tx, ty, tz, s, rx, ry, rz]`.
  ///
  /// Units of parameters: `t` in metres, `s` in ppm, `r` in arcseconds.
  const Datum({
    required this.ellipsoid,
    required this.transform,
  });

  /// The `WGS84` (World Geodetic System 1984) datum.
  static const WGS84 = Datum(
    ellipsoid: Ellipsoid.WGS84,
    transform: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
  );

  /// The `ETRS89` (European Terrestrial Reference System 1989) datum.
  ///
  /// ETRS89 reference frames are coincident with [WGS84] at epoch 1989.0 (ie.
  /// null transform) at the one metre level.
  static const ETRS89 = Datum(
    ellipsoid: Ellipsoid.GRS80,
    transform: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
  ); // epsg.io/1149; @ 1-metre level

  /// The `ED50` (European Datum 1950) datum.
  static const ED50 = Datum(
    ellipsoid: HistoricalEllipsoids.Intl1924,
    transform: [89.5, 93.8, 123.1, -1.2, 0.0, 0.0, 0.156],
  ); // epsg.io/1311

  /// The `Irl1975` (Ireland 1975) datum.
  static const Irl1975 = Datum(
    ellipsoid: HistoricalEllipsoids.AiryModified,
    transform: [-482.530, 130.596, -564.557, -8.150, 1.042, 0.214, 0.631],
  ); // epsg.io/1954

  /// The `NAD27` (North American Datum 1927) datum.
  static const NAD27 = Datum(
    ellipsoid: HistoricalEllipsoids.Clarke1866,
    transform: [8, -160, -176, 0, 0, 0, 0],
  );

  /// The `NAD83` (North American Datum 1983) datum.
  static const NAD83 = Datum(
    ellipsoid: Ellipsoid.GRS80,
    transform: [
      0.9956,
      -1.9103,
      -0.5215,
      -0.00062,
      0.025915,
      0.009426,
      0.011599,
    ],
  );

  /// The `NTF` (Nouvelle Triangulation Francaise) datum.
  static const NTF = Datum(
    ellipsoid: HistoricalEllipsoids.Clarke1880IGN,
    transform: [168, 60, -320, 0, 0, 0, 0],
  );

  /// The `OSGB36` (Ordnance Survey Great Britain 1936) datum.
  static const OSGB36 = Datum(
    ellipsoid: HistoricalEllipsoids.Airy1830,
    transform: [
      -446.448,
      125.157,
      -542.060,
      20.4894,
      -0.1502,
      -0.2470,
      -0.8421,
    ],
  ); // epsg.io/1314

  /// The `Potsdam` datum.
  static const Potsdam = Datum(
    ellipsoid: HistoricalEllipsoids.Bessel1841,
    transform: [-582, -105, -414, -8.3, 1.04, 0.35, -3.08],
  );

  /// The `TokyoJapan` datum.
  static const TokyoJapan = Datum(
    ellipsoid: HistoricalEllipsoids.Bessel1841,
    transform: [148, -507, -685, 0, 0, 0, 0],
  );

  /// The `WGS72` (World Geodetic System 1972) datum.
  static const WGS72 = Datum(
    ellipsoid: HistoricalEllipsoids.WGS72,
    transform: [0, 0, -4.5, -0.22, 0, 0, 0.554],
  );

  /// Converts the [geographic] position in this datum to another datum specified
  /// by [to].
  ///
  /// The geographic position is first converted to geocentric cartesian, then
  /// the Helmert 7-parameter transformation is applied to convert the position,
  /// and finally the result is converted back to a geographic position.
  ///
  /// The returned position is a geographic position in the [to] datum.
  Geographic convertGeographic(Geographic geographic, {required Datum to}) {
    // using `this` datum to get geocentric position in `this` datum
    final geocentric = Ellipsoidal.fromGeographic(geographic, datum: this)
        .toGeocentricCartesian();

    // using `to` datum to convert geocentric position to `to` datum
    final converted = convertGeocentricCartesian(geocentric, to: to);

    // using `to` datum to get geographic position from geocentric position
    // (omit the elevation if the input geographic position was 2D even if
    //  elevation could be non-zero after conversion to another datum)
    return Geocentric.fromGeocentricCartesian(converted, datum: to)
        .toGeographic(omitElev: !geographic.is3D);
  }

  /// Converts the geocentric [cartesian] position (X, Y, Z) in this datum to
  /// another datum a specified by [to] using the Helmert 7-parameter
  /// transformation.
  ///
  /// The returned position is a geocentric cartesian position (X, Y, Z) in the
  /// [to] datum.
  Position convertGeocentricCartesian(Position cartesian, {required Datum to}) {
    if (this == to) {
      // no datum change
      return cartesian;
    } else if (this == WGS84) {
      // converting from WGS 84
      return _applyTransform(cartesian, to.transform);
    } else if (to == WGS84) {
      // converting to WGS 84; use inverse transform
      return _applyTransform(
        cartesian,
        transform.map((e) => -e).toList(growable: false),
      );
    }

    // neither this.datum nor toDatum are WGS84: convert origin to WGS84 first
    return _applyTransform(
      convertGeocentricCartesian(cartesian, to: WGS84),
      to.transform,
    );
  }

  Position _applyTransform(Position origin, List<double> t) {
    final x1 = origin.x;
    final y1 = origin.y;
    final z1 = origin.z;

    // transform parameters

    // x-shift in metres
    final tx = t[0];
    // y-shift in metres
    final ty = t[1];
    // z-shift in metres
    final tz = t[2];
    // scale: normalise parts-per-million to (s+1)
    final s = t[3] / 1.0e6 + 1.0;
    // x-rotation: normalise arcseconds to radians
    final rx = (t[4] / 3600.0).toRadians();
    // y-rotation: normalise arcseconds to radians
    final ry = (t[5] / 3600.0).toRadians();
    // z-rotation: normalise arcseconds to radians
    final rz = (t[6] / 3600.0).toRadians();

    // apply transform
    final x2 = tx + x1 * s - y1 * rz + z1 * ry;
    final y2 = ty + x1 * rz + y1 * s - z1 * rx;
    final z2 = tz - x1 * ry + y1 * rx + z1 * s;

    return Position.create(
      x: x2,
      y: y2,
      z: z2,
      m: origin.optM, // do not convert optional M value
    );
  }

  @override
  String toString() => '$ellipsoid;${listToString(transform)}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Datum &&
          ellipsoid == other.ellipsoid &&
          testListEquality(transform, other.transform));

  @override
  int get hashCode => Object.hash(ellipsoid, Object.hashAll(transform));
}

/// Some historical geodetic ellipsoids defined as static constants.
///
/// See also [Datum] for historical datums based on these ellipsoids along with
/// datum transformation parameters.
class HistoricalEllipsoids {
  const HistoricalEllipsoids._();

  /// Ellisoidal parameters for the `Airy1830` reference ellipsoid.
  static const Airy1830 = Ellipsoid(
    id: 'airy',
    name: 'Airy 1830',
    a: 6377563.396,
    b: 6356256.909,
    f: 1.0 / 299.3249646,
  );

  /// Ellisoidal parameters for the `AiryModified` reference ellipsoid.
  static const AiryModified = Ellipsoid(
    id: 'mod_airy',
    name: 'Modified Airy',
    a: 6377340.189,
    b: 6356034.448,
    f: 1.0 / 299.3249646,
  );

  /// Ellisoidal parameters for the `Bessel1841` reference ellipsoid.
  static const Bessel1841 = Ellipsoid(
    id: 'bessel',
    name: 'Bessel 1841',
    a: 6377397.155,
    b: 6356078.962822,
    f: 1.0 / 299.15281285,
  );

  /// Ellisoidal parameters for the `Clarke1866` reference ellipsoid.
  static const Clarke1866 = Ellipsoid(
    id: 'clrk66',
    name: 'Clarke 1866',
    a: 6378206.4,
    b: 6356583.8,
    f: 1.0 / 294.978698214,
  );

  /// Ellisoidal parameters for the `Clarke1880` reference ellipsoid.
  static const Clarke1880IGN = Ellipsoid(
    id: 'clrk80',
    name: 'Clarke 1880 mod.',
    a: 6378249.2,
    b: 6356515.0,
    f: 1.0 / 293.466021294,
  );

  /// Ellisoidal parameters for the `Intl1924` (aka Hayford or International
  /// 1909/1924) reference ellipsoid.
  static const Intl1924 = Ellipsoid(
    id: 'intl',
    name: 'International 1924 (Hayford)',
    a: 6378388,
    b: 6356911.946128,
    f: 1.0 / 297,
  );

  /// Ellisoidal parameters for the `WGS72` reference ellipsoid.
  static const WGS72 = Ellipsoid(
    id: 'WGS72',
    name: 'WGS 72',
    a: 6378135,
    b: 6356750.52,
    f: 1.0 / 298.26,
  );
}
