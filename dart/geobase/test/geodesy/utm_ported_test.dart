/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Geodesy Test Harness - utm/mgrs                                    (c) Chris Veness 2014-2021  */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// Utm/mgrs tests by Chris Veness ported to Dart by Navibyte.
//
// Source:
// https://github.com/chrisveness/geodesy/blob/master/test/utm-mgrs-tests.js

// ignore_for_file: require_trailing_commas, lines_longer_than_80_chars

import 'package:geobase/common.dart';
import 'package:geobase/coordinates.dart';
import 'package:geobase/geodesy.dart';

import 'package:test/test.dart';

// useful for manual checks: www.rcn.montana.edu/resources/converter.aspx

void main() {
  group('@examples UTM', () {
    test('constructor', () {
      expect(Utm(31, 'N', 448251, 5411932).toText(), '31 N 448251 5411932');
    });

    test('toLatLon', () {
      expect(Utm(31, 'N', 448251.795, 5411932.678).toGeographic().latLonDms(),
          '48.8582°N, 2.2945°E');
    });

    test('parse', () {
      expect(Utm.parse('31 N 448251 5411932').toText(), '31 N 448251 5411932');
    });

    test('toString', () {
      expect(Utm(31, 'N', 448251.1, 5411932.1).toText(decimals: 4),
          '31 N 448251.1000 5411932.1000');
    });

    test('README', () {
      final geo1 = Utm.parse('48 N 377298.745 1483034.794').toGeographic();
      final utm2 = Utm.fromGeographic(geo1);
      expect(utm2.toText(decimals: 3), '48 N 377298.745 1483034.794');
    });
  });

  group('@examples LatLon', () {
    test('toUtm', () {
      const geo1 = Geographic(lat: 48.8582, lon: 2.2945);
      final utm2 = Utm.fromGeographic(geo1);
      expect(utm2.toText(), '31 N 448252 5411933');
    });
  });

  group('UTM constructor fail', () {
    test('zone fail', () {
      expect(() => Utm(0, 'N', 0, 0), throwsFormatException);
    });

    test('zone fail', () {
      expect(() => Utm(61, 'N', 0, 0), throwsFormatException);
    });

    test('hemisphere fail', () {
      expect(() => Utm(1, 'E', 0, 0), throwsFormatException);
    });

    test('easting fail', () {
      expect(() => Utm(1, 'N', 1001e3, 0), throwsFormatException);
    });

    test('northing N fail', () {
      expect(() => Utm(1, 'N', 0, 9330e3), throwsFormatException);
    });

    test('northing S fail', () {
      expect(() => Utm(1, 'S', 0, 1116e3), throwsFormatException);
    });
  });

  group('latitude/longitude -> UTM', () {
    test('0,0', () {
      const geo1 = Geographic(lat: 0, lon: 0);
      expect(
          Utm.fromGeographic(geo1).toText(decimals: 6), '31 N 166021.443081 0');
    });

    test('1,1', () {
      const geo1 = Geographic(lat: 1, lon: 1);
      expect(Utm.fromGeographic(geo1).toText(decimals: 5),
          '31 N 277438.26352 110597.97252');
    });

    test('-1,-1', () {
      const geo1 = Geographic(lat: -1, lon: -1);
      expect(Utm.fromGeographic(geo1).toText(decimals: 5),
          '30 S 722561.73648 9889402.02748');
    });

    test('1,1 Z31', () {
      const geo1 = Geographic(lat: 1, lon: 1);
      expect(Utm.fromGeographic(geo1, zone: 30).toText(decimals: 5),
          '30 N 945396.68398 110801.83255');
    });

    test('eiffel tower', () {
      const geo1 = Geographic(lat: 48.8583, lon: 2.2945);
      expect(Utm.fromGeographic(geo1).toText(decimals: 3),
          '31 N 448251.898 5411943.794');
    });

    test('sidney o/h', () {
      const geo1 = Geographic(lat: -33.857, lon: 151.215);
      expect(Utm.fromGeographic(geo1).toText(decimals: 3),
          '56 S 334873.199 6252266.092');
    });

    test('white house', () {
      const geo1 = Geographic(lat: 38.8977, lon: -77.0365);
      expect(Utm.fromGeographic(geo1).toText(decimals: 3),
          '18 N 323394.296 4307395.634');
    });

    test('rio christ', () {
      const geo1 = Geographic(lat: -22.9519, lon: -43.2106);
      expect(Utm.fromGeographic(geo1).toText(decimals: 3),
          '23 S 683466.254 7460687.433');
    });

    test('bergen', () {
      const geo1 = Geographic(lat: 60.39135, lon: 5.3249);
      expect(Utm.fromGeographic(geo1).toText(decimals: 2),
          '32 N 297508.41 6700645.30');
    });

    test('bergen convergence', () {
      const geo1 = Geographic(lat: 60.39135, lon: 5.3249);
      expect(Utm.fromGeographicMeta(geo1).convergence, -3.196281440);
    });

    test('bergen scale', () {
      const geo1 = Geographic(lat: 60.39135, lon: 5.3249);
      expect(Utm.fromGeographicMeta(geo1).scale, 1.000102473211);
    });
  });

  group('UTM -> latitude/longitude', () {
    test('0,0', () {
      expect(
          Utm.parse('31 N 166021.443081 0.000000').toGeographic().latLonDms(),
          '0.0000°N, 0.0000°E');
    });

    test('1,1', () {
      expect(
          Utm.parse('31 N 277438.263521 110597.972524')
              .toGeographic()
              .latLonDms(),
          '1.0000°N, 1.0000°E');
    });

    test('-1,-1', () {
      expect(
          Utm.parse('30 S 722561.736479 9889402.027476')
              .toGeographic()
              .latLonDms(),
          '1.0000°S, 1.0000°W');
    });

    test('eiffel tower', () {
      expect(
          Utm.parse('31 N 448251.898 5411943.794').toGeographic().latLonDms(),
          '48.8583°N, 2.2945°E');
    });

    test('sidney o/h', () {
      expect(
          Utm.parse('56 S 334873.199 6252266.092').toGeographic().latLonDms(),
          '33.8570°S, 151.2150°E');
    });

    test('white house', () {
      expect(
          Utm.parse('18 N 323394.296 4307395.634').toGeographic().latLonDms(),
          '38.8977°N, 77.0365°W');
    });

    test('rio christ', () {
      expect(
          Utm.parse('23 S 683466.254 7460687.433').toGeographic().latLonDms(),
          '22.9519°S, 43.2106°W');
    });

    test('bergen', () {
      expect(
          Utm.parse('32 N 297508.410 6700645.296').toGeographic().latLonDms(),
          '60.3914°N, 5.3249°E');
    });

    test('bergen convergence', () {
      expect(
          Utm.parse('32 N 297508.410 6700645.296')
              .toGeographicMeta()
              .convergence,
          -3.196281443);
    });

    test('bergen scale', () {
      expect(Utm.parse('32 N 297508.410 6700645.296').toGeographicMeta().scale,
          1.000102473212);
    });

    test('bergen scale - no rounding', () {
      expect(
          Utm.parse('32 N 297508.410 6700645.296')
              .toGeographicMeta(roundResults: false)
              .scale,
          1.0001024732117445);
    });
  });

  group('ED50 conversion', () {
    const degMinSec = Dms(type: DmsType.degMinSec, decimals: 3);
    final helmertturm = // epsg.io/23033
        Utm(33, 'N', 368381.402, 5805291.614, datum: Datum.ED50);
    final llED50 = helmertturm.toGeographic();
    final llWGS84 = Datum.ED50.convertGeographic(llED50, to: Datum.WGS84);
    final llWGS84WithoutElev = llWGS84.copyByType(Coords.xy);
    test('helmertturm ED50', () {
      // earth-info.nga.mil/GandG/coordsys/datums/datumorigins.html
      expect(llED50.latLonDms(format: degMinSec),
          '52°22′51.446″N, 13°03′58.741″E');
    });
    test('helmertturm WGS84', () {
      expect(llWGS84WithoutElev.latLonDms(format: degMinSec),
          '52°22′48.931″N, 13°03′54.824″E');
    });
  });

  group('IBM coordconvert', () {
    // https://www.ibm.com/developerworks/library/j-coordconvert/#listing7
    // (note UTM/MGRS confusion; UTM is rounded, MGRS is truncated;
    //  UPS not included)

    test('#01 UTM->LL', () {
      expect(Utm.parse('31 N 166021 0').toGeographic().latLonDms(),
          '0.0000°N, 0.0000°W');
    });

    test('#02 UTM->LL', () {
      expect(Utm.parse('30 N 808084 14385').toGeographic().latLonDms(),
          '0.1300°N, 0.2324°W');
    });

    test('#03 UTM->LL', () {
      expect(Utm.parse('34 S 683473 4942631').toGeographic().latLonDms(),
          '45.6456°S, 23.3545°E');
    });

    test('#04 UTM->LL', () {
      expect(Utm.parse('25 S 404859 8588690').toGeographic().latLonDms(),
          '12.7650°S, 33.8765°W');
    });

    test('#09 UTM->LL', () {
      expect(Utm.parse('08 N 453580 2594272').toGeographic().latLonDms(),
          '23.4578°N, 135.4545°W');
    });

    test('#10 UTM->LL', () {
      expect(Utm.parse('57 N 450793 8586116').toGeographic().latLonDms(),
          '77.3450°N, 156.9876°E');
    });
  });

  group('UTM fail', () {
    test('zone fail', () {
      // latitude ‘85’ outside UTM limits
      expect(() => Utm.fromGeographic(const Geographic(lat: 85, lon: 0)),
          throwsFormatException);
    });
  });

  group('Norway/Svalbard adjustmen', () {
    test('Norway 31->32', () {
      expect(Utm.fromGeographic(const Geographic(lat: 60, lon: 4)).zone, 32);
    });

    test('Svalbard 32->31', () {
      expect(Utm.fromGeographic(const Geographic(lat: 75, lon: 8)).zone, 31);
    });

    test('Svalbard 32->33', () {
      expect(Utm.fromGeographic(const Geographic(lat: 75, lon: 10)).zone, 33);
    });

    test('Svalbard 34->33', () {
      expect(Utm.fromGeographic(const Geographic(lat: 75, lon: 20)).zone, 33);
    });

    test('Svalbard 34->35', () {
      expect(Utm.fromGeographic(const Geographic(lat: 75, lon: 22)).zone, 35);
    });

    test('Svalbard 36->35', () {
      expect(Utm.fromGeographic(const Geographic(lat: 75, lon: 32)).zone, 35);
    });

    test('Svalbard 36->37', () {
      expect(Utm.fromGeographic(const Geographic(lat: 75, lon: 34)).zone, 37);
    });
  });
}
