// ignore_for_file: avoid_redundant_argument_values

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

// see also `utm_test.dart` for more tests on UTM/MGRS

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

  group('@examples MGRS', () {
    test('constructor', () {
      expect(
          Mgrs(31, 'U', 'D', 'Q', 48251, 11932).toText(), '31U DQ 48251 11932');
    });

    test('toUtm', () {
      expect(Mgrs.parse('31U DQ 48251 11932').toUtm().toText(),
          '31 N 448251 5411932');
    });

    test('parse', () {
      expect(Mgrs.parse('31U DQ 48251 11932').toText(), '31U DQ 48251 11932');
    });

    test('parse military-style', () {
      expect(Mgrs.parse('31UDQ4825111932').toText(), '31U DQ 48251 11932');
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

  group('MGRS constructor fail', () {
    test('bad zone', () {
      // 'invalid MGRS zone ‘0’'
      expect(() => Mgrs(0, 'C', 'A', 'A', 0, 0), throwsFormatException);
    });

    test('bad band', () {
      // 'invalid MGRS band ‘A’'
      expect(() => Mgrs(1, 'A', 'A', 'A', 0, 0), throwsFormatException);
    });

    test('bad grid sq easting', () {
      // 'invalid MGRS 100km grid square column ‘I’ for zone 1'
      expect(() => Mgrs(1, 'C', 'I', 'A', 0, 0), throwsFormatException);
    });

    test('bad grid sq northing', () {
      // 'invalid MGRS 100km grid square row ‘I’'
      expect(() => Mgrs(1, 'C', 'A', 'I', 0, 0), throwsFormatException);
    });

    test('invalid grid sq e', () {
      // 'invalid MGRS 100km grid square column ‘A’ for zone 2'
      expect(() => Mgrs(2, 'C', 'A', 'A', 0, 0), throwsFormatException);
    });

    test('big easting', () {
      // 'invalid MGRS easting ‘999999’'
      expect(() => Mgrs(1, 'C', 'A', 'A', 999999, 0), throwsFormatException);
    });

    test('big northing', () {
      // 'invalid MGRS northing ‘999999’'
      expect(() => Mgrs(1, 'C', 'A', 'A', 0, 999999), throwsFormatException);
    });

    test('bad multiples', () {
      // 'invalid MGRS band ‘A’, invalid MGRS 100km grid square row ‘I’'
      expect(() => Mgrs(1, 'A', 'A', 'I', 0, 0), throwsFormatException);
    });
  });

  group('toString', () {
    test('toString fail', () {
      // 'invalid precision ‘3’'
      expect(() => Mgrs(1, 'C', 'A', 'A', 0, 0).toText(digits: 3),
          throwsFormatException);
    });
  });

  group('MGRS parse', () {
    // note Wikipedia considers 4Q & 4Q FJ to be valid MGRS values; this library
    //expects easting & northing;

    test('Wikipedia 4Q FJ 1 6', () {
      expect(Mgrs.parse('4Q FJ 1 6').toText(digits: 2), '4Q FJ 1 6');
      expect(Mgrs.parse('4Q FJ 1 6').toText(digits: 2, zeroPadZone: true),
          '04Q FJ 1 6');
    });

    test('Wikipedia 4Q FJ 12 67', () {
      expect(Mgrs.parse('4Q FJ 12 67').toText(digits: 4), '4Q FJ 12 67');
    });

    test('Wikipedia 4Q FJ 123 678', () {
      expect(Mgrs.parse('4Q FJ 123 678').toText(digits: 6), '4Q FJ 123 678');
    });

    test('Wikipedia 4Q FJ 1234 6789', () {
      expect(
          Mgrs.parse('4Q FJ 1234 6789').toText(digits: 8), '4Q FJ 1234 6789');
    });

    test('Wikipedia 4Q FJ 12345 67890', () {
      expect(Mgrs.parse('4Q FJ 12345 67890').toText(digits: 10),
          '4Q FJ 12345 67890');
    });

    // Defense Mapping Agency Technical Manual 8358.1: Datums, Ellipsoids,
    // Grids, and Grid Reference Systems 3-4

    test('DMA 18SUU80', () {
      expect(Mgrs.parse('18SUU80').toText(digits: 2), '18S UU 8 0');
    });

    test('DMA 18SUU8401', () {
      expect(Mgrs.parse('18SUU8401').toText(digits: 4), '18S UU 84 01');
    });

    test('DMA 18SUU8360140', () {
      expect(Mgrs.parse('18SUU836014').toText(digits: 6), '18S UU 836 014');
    });

    test('parse fail 2', () {
      expect(() => Mgrs.parse('Cambridge'), throwsFormatException);
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

  group('latitude/longitude -> UTM - ellipsoidal extension', () {
    test('bergen', () {
      const geo1 = Geographic(lat: 60.39135, lon: 5.3249);
      expect(geo1.toUtm().toText(decimals: 2), '32 N 297508.41 6700645.30');
    });

    test('bergen scale', () {
      const geo1 = Geographic(lat: 60.39135, lon: 5.3249);
      expect(geo1.toUtmMeta().scale, 1.000102473211);
    });
  });

  group('UTM -> latitude/longitude', () {
    test('0,0', () {
      expect(
          Utm.parse('31 N 166021.443081 0.000000').toGeographic().latLonDms(),
          '0.0000°N, 0.0000°E');
      expect(
          UtmZone.fromGeographic(
              Geographic.parseDms(lat: '0.0000°N', lon: '0.0000°E')),
          UtmZone(31, 'N'));
    });

    test('1,1', () {
      expect(
          Utm.parse('31 N 277438.263521 110597.972524')
              .toGeographic()
              .latLonDms(),
          '1.0000°N, 1.0000°E');
      expect(
          UtmZone.fromGeographic(
              Geographic.parseDms(lat: '1.0000°N', lon: '1.0000°E')),
          UtmZone(31, 'N'));
    });

    test('-1,-1', () {
      expect(
          Utm.parse('30 S 722561.736479 9889402.027476')
              .toGeographic()
              .latLonDms(),
          '1.0000°S, 1.0000°W');
      expect(
          UtmZone.fromGeographic(
              Geographic.parseDms(lat: '1.0000°S', lon: '1.0000°W')),
          UtmZone(30, 'S'));
    });

    test('eiffel tower', () {
      expect(
          Utm.parse('31 N 448251.898 5411943.794').toGeographic().latLonDms(),
          '48.8583°N, 2.2945°E');
      expect(
          UtmZone.fromGeographic(
              Geographic.parseDms(lat: '48.8583°N', lon: '2.2945°E')),
          UtmZone(31, 'N'));
    });

    test('sidney o/h', () {
      expect(
          Utm.parse('56 S 334873.199 6252266.092').toGeographic().latLonDms(),
          '33.8570°S, 151.2150°E');
      expect(
          UtmZone.fromGeographic(
              Geographic.parseDms(lat: '33.8570°S', lon: '151.2150°E')),
          UtmZone(56, 'S'));
    });

    test('white house', () {
      expect(
          Utm.parse('18 N 323394.296 4307395.634').toGeographic().latLonDms(),
          '38.8977°N, 77.0365°W');
      expect(
          UtmZone.fromGeographic(
              Geographic.parseDms(lat: '38.8977°N', lon: '77.0365°W')),
          UtmZone(18, 'N'));
    });

    test('rio christ', () {
      expect(
          Utm.parse('23 S 683466.254 7460687.433').toGeographic().latLonDms(),
          '22.9519°S, 43.2106°W');
      expect(
          UtmZone.fromGeographic(
              Geographic.parseDms(lat: '22.9519°S', lon: '43.2106°W')),
          UtmZone(23, 'S'));
    });

    test('bergen', () {
      expect(
          Utm.parse('32 N 297508.410 6700645.296').toGeographic().latLonDms(),
          '60.3914°N, 5.3249°E');
      expect(
          UtmZone.fromGeographic(
              Geographic.parseDms(lat: '60.3914°N', lon: '5.3249°E')),
          UtmZone(32, 'N'));
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

  group('UTM -> MGRS', () {
    test('0,0', () {
      expect(Utm.parse('31 N 166021.443081 0.000000').toMgrs().toText(),
          '31N AA 66021 00000');
    });

    test('1,1', () {
      expect(Utm.parse('31 N 277438.263521 110597.972524').toMgrs().toText(),
          '31N BB 77438 10597');
    });

    test('-1,-1', () {
      expect(Utm.parse('30 S 722561.736479 9889402.027476').toMgrs().toText(),
          '30M YD 22561 89402');
    });

    test('eiffel tower', () {
      expect(Utm.parse('31 N 448251.898 5411943.794').toMgrs().toText(),
          '31U DQ 48251 11943');
    });

    test('sidney o/h', () {
      expect(Utm.parse('56 S 334873.199 6252266.092').toMgrs().toText(),
          '56H LH 34873 52266');
    });

    test('white house', () {
      expect(Utm.parse('18 N 323394.296 4307395.634').toMgrs().toText(),
          '18S UJ 23394 07395');
    });

    test('rio christ', () {
      expect(Utm.parse('23 S 683466.254 7460687.433').toMgrs().toText(),
          '23K PQ 83466 60687');
    });

    test('bergen', () {
      expect(Utm.parse('32 N 297508.410 6700645.296').toMgrs().toText(),
          '32V KN 97508 00645');
    });
  });

  group('MGRS -> UTM', () {
    test('0,0', () {
      expect(
          Mgrs.parse('31N AA 66021 00000').toUtm().toText(), '31 N 166021 0');
    });

    test('1,1', () {
      expect(Mgrs.parse('31N BB 77438 10597').toUtm().toText(),
          '31 N 277438 110597');
    });

    test('-1,-1', () {
      expect(Mgrs.parse('30M YD 22561 89402').toUtm().toText(),
          '30 S 722561 9889402');
    });

    test('eiffel tower', () {
      expect(Mgrs.parse('31U DQ 48251 11943').toUtm().toText(),
          '31 N 448251 5411943');
    });

    test('sidney o/h', () {
      expect(Mgrs.parse('56H LH 34873 52266').toUtm().toText(),
          '56 S 334873 6252266');
    });

    test('white house', () {
      expect(Mgrs.parse('18S UJ 23394 07395').toUtm().toText(),
          '18 N 323394 4307395');
    });

    test('rio christ', () {
      expect(Mgrs.parse('23K PQ 83466 60687').toUtm().toText(),
          '23 S 683466 7460687');
    });

    test('bergen', () {
      expect(Mgrs.parse('32V KN 97508 00645').toUtm().toText(),
          '32 N 297508 6700645');
    });

    // forgiving parsing of 100km squares spanning bands

    test('01P ≡ UTM 01Q', () {
      expect(Mgrs.parse('01P ET 00000 68935').toUtm().toText(),
          '1 N 500000 1768935');
    });

    test('01Q ≡ UTM 01P', () {
      expect(Mgrs.parse('01Q ET 00000 68935').toUtm().toText(zeroPadZone: true),
          '01 N 500000 1768935');
    });

    // use correct latitude band base northing [#73]

    test('nBand @ 3°', () {
      expect(Utm.parse('31 N 500000 7097014').toMgrs().toUtm().toText(),
          '31 N 500000 7097014');
    });
  });

  group('round-tripping', () {
    test('David Smith (CCS) N-0°', () {
      expect(
          const Geographic(lat: 64, lon: 0)
              .toUtm()
              .toMgrs()
              .toUtm()
              .toGeographic()
              .latLonDms(),
          '64.0000°N, 0.0000°W');
    });

    test('David Smith (CCS) N-3°', () {
      expect(
          const Geographic(lat: 64, lon: 3)
              .toUtm()
              .toMgrs()
              .toUtm()
              .toGeographic()
              .latLonDms(),
          '64.0000°N, 3.0000°E');
    });

    test('David Smith (CCS) S-0°', () {
      expect(
          const Geographic(lat: -64, lon: 0)
              .toUtm()
              .toMgrs()
              .toUtm()
              .toGeographic()
              .latLonDms(),
          '64.0000°S, 0.0000°W');
    });

    test('David Smith (CCS) S-3°', () {
      expect(
          const Geographic(lat: -64, lon: 3)
              .toUtm()
              .toMgrs()
              .toUtm()
              .toGeographic()
              .latLonDms(),
          '64.0000°S, 3.0000°E');
    });

    test('Rounding error @ 80°S', () {
      expect(
          const Geographic(lat: -80, lon: 0).toUtm().toGeographic().latLonDms(),
          '80.0000°S, 0.0000°E');
      expect(
          const Geographic(lat: -80, lon: 0)
              .toUtm()
              .toMgrs()
              .toUtm()
              .toGeographic()
              .latLonDms(),
          '80.0000°S, 0.0000°W');
    });
  });

  group('ED50 conversion', () {
    const degMinSec = Dms(type: DmsType.degMinSec, decimals: 3);
    final helmertturm = // epsg.io/23033
        Utm(33, 'N', 368381.402, 5805291.614, datum: Datum.ED50);
    final llED50 = helmertturm.toGeographic();
    final llWGS84 = Datum.ED50.convertGeographic(llED50, target: Datum.WGS84);
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

    test('#01 LL->UTM', () {
      expect(const Geographic(lat: 0.0000, lon: 0.0000).toUtm().toText(),
          '31 N 166021 0');
    });

    test('#01 LL->MGRS', () {
      expect(
          const Geographic(lat: 0.0000, lon: 0.0000).toUtm().toMgrs().toText(),
          '31N AA 66021 00000');
    });

    test('#02 LL->UTM', () {
      expect(const Geographic(lat: 0.1300, lon: -0.2324).toUtm().toText(),
          '30 N 808084 14386');
    });

    test('#02 LL->MGRS', () {
      expect(
          const Geographic(lat: 0.1300, lon: -0.2324).toUtm().toMgrs().toText(),
          '30N ZF 08084 14385');
    });

    test('#03 LL->UTM', () {
      expect(const Geographic(lat: -45.6456, lon: 23.3545).toUtm().toText(),
          '34 S 683474 4942631');
    });

    test('#03 LL->MGRS', () {
      expect(
          const Geographic(lat: -45.6456, lon: 23.3545)
              .toUtm()
              .toMgrs()
              .toText(),
          '34G FQ 83473 42631');
    });

    test('#04 LL->UTM', () {
      expect(const Geographic(lat: -12.7650, lon: -33.8765).toUtm().toText(),
          '25 S 404859 8588691');
    });

    test('#04 LL->MGRS', () {
      expect(
          const Geographic(lat: -12.7650, lon: -33.8765)
              .toUtm()
              .toMgrs()
              .toText(),
          '25L DF 04859 88691');
    });

    test('#09 LL->UTM', () {
      expect(const Geographic(lat: 23.4578, lon: -135.4545).toUtm().toText(),
          '8 N 453580 2594273');
    });

    test('#09 LL->MGRS', () {
      expect(
          const Geographic(lat: 23.4578, lon: -135.4545)
              .toUtm()
              .toMgrs()
              .toText(zeroPadZone: true),
          '08Q ML 53580 94272');
    });

    test('#10 LL->UTM', () {
      expect(const Geographic(lat: 77.3450, lon: 156.9876).toUtm().toText(),
          '57 N 450794 8586116');
    });

    test('#10 LL->MGRS', () {
      expect(
          const Geographic(lat: 77.3450, lon: 156.9876)
              .toUtm()
              .toMgrs()
              .toText(),
          '57X VF 50793 86116');
    });
  });

  group('MGRS varying resolution', () {
    test('MGRS 4-digit -> UTM', () {
      expect(
          Mgrs.parse('12S TC 52 86').toUtm().toText(), '12 N 252000 3786000');
    });

    test('MGRS 10-digit -> UTM', () {
      expect(Mgrs.parse('12S TC 52000 86000').toUtm().toText(),
          '12 N 252000 3786000');
    });

    test('MGRS 10-digit+decimals', () {
      expect(
          Mgrs.parse('12S TC 52000.123 86000.123')
              .toUtm()
              .toText(decimals: 3, compactNums: false),
          '12 N 252000.000 3786000.000');
    });

    test('MGRS truncate', () {
      expect(Mgrs.parse('12S TC 52999.999 86999.999').toText(digits: 6),
          '12S TC 529 869');
    });

    test('MGRS-UTM truncate', () {
      expect(Mgrs.parse('12S TC 52999.999 86999.999').toUtm().toText(),
          '12 N 252999 3786999');
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
      const geo = Geographic(lat: 60, lon: 4);
      expect(Utm.fromGeographic(geo).zone, 32);
      expect(UtmZone.fromGeographic(geo).zone, 32);
    });

    test('Svalbard 32->31', () {
      const geo = Geographic(lat: 75, lon: 8);
      expect(Utm.fromGeographic(geo).zone, 31);
      expect(UtmZone.fromGeographic(geo).zone, 31);
    });

    test('Svalbard 32->33', () {
      const geo = Geographic(lat: 75, lon: 10);
      expect(Utm.fromGeographic(geo).zone, 33);
      expect(UtmZone.fromGeographic(geo).zone, 33);
    });

    test('Svalbard 34->33', () {
      const geo = Geographic(lat: 75, lon: 20);
      expect(Utm.fromGeographic(geo).zone, 33);
      expect(UtmZone.fromGeographic(geo).zone, 33);
    });

    test('Svalbard 34->35', () {
      const geo = Geographic(lat: 75, lon: 22);
      expect(Utm.fromGeographic(geo).zone, 35);
      expect(UtmZone.fromGeographic(geo).zone, 35);
    });

    test('Svalbard 36->35', () {
      const geo = Geographic(lat: 75, lon: 32);
      expect(Utm.fromGeographic(geo).zone, 35);
      expect(UtmZone.fromGeographic(geo).zone, 35);
    });

    test('Svalbard 36->37', () {
      const geo = Geographic(lat: 75, lon: 34);
      expect(Utm.fromGeographic(geo).zone, 37);
      expect(UtmZone.fromGeographic(geo).zone, 37);
    });
  });
}
