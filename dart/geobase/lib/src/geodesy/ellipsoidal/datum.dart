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
/* note:
 * - ETRS89 reference frames are coincident with WGS-84 at epoch 1989.0 (ie null transform) at the one metre level.
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

import '/src/common/reference/ellipsoid.dart';

/// Some historical geodetic ellipsoids defined as static constants.
class HistoricalEllipsoids {

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
