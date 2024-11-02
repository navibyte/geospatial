/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Geodesy Test Harness - latlon-ellipsoidal-vincenty                 (c) Chris Veness 2014-2022  */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// Vincenty Direct and Inverse Solution of Geodesics on the Ellipsoid by Chris
// Veness ported to Dart by Navibyte.
//
// Source:
// https://github.com/chrisveness/geodesy/blob/master/test/latlon-ellipsoidal-vincenty-tests.js

// ignore_for_file: lines_longer_than_80_chars

import 'package:geobase/common.dart';
import 'package:geobase/coordinates.dart';
import 'package:geobase/geodesy.dart';

import 'package:test/test.dart';

String _fixed(double value, int decimals) => value.toStringAsFixed(decimals);

void main() {
  group('latlon-ellipsoidal-vincenty / examples', () {
    final p1 = const Geographic(lat: 50.06632, lon: -5.71475).vincenty();
    const dest1 = Geographic(lat: 58.64402, lon: -3.07009);
    final p2 = const Geographic(lat: -37.95103, lon: 144.42487).vincenty();

    test(
      'distanceTo',
      () => expect(p1.distanceTo(dest1).toStringAsFixed(3), '969954.166'),
    );

    test(
      'initialBearingTo',
      () => expect(p1.initialBearingTo(dest1).toStringAsFixed(4), '9.1419'),
    );

    test(
      'finalBearingTo',
      () => expect(p1.finalBearingTo(dest1).toStringAsFixed(4), '11.2972'),
    );

    test(
      'destinationPoint',
      () {
        final dest =
            p2.destinationPoint(distance: 54972.271, bearing: 306.86816);
        expect(dest.latLonDms(), '37.6528°S, 143.9265°E');
      },
    );

    test(
      'finalBearingOn',
      () {
        final brng = p2.finalBearingOn(distance: 54972.271, bearing: 306.86816);
        expect(brng.toStringAsFixed(4), '307.1736');
      },
    );

    test(
      'intermediatePointTo',
      () {
        final dest = p1.intermediatePointTo(dest1, fraction: 0.5);
        expect(dest.latLonDms(), '54.3639°N, 4.5304°W');
      },
    );

    test(
      'midPointTo',
      () {
        final dest = p1.midPointTo(dest1);
        expect(dest.latLonDms(), '54.3639°N, 4.5304°W');
      },
    );
  });

  group('latlon-ellipsoidal-vincenty', () {
    const circMeridional = 40007862.918;

    test('Rainsford (from TV Direct & Inverse Solutions)', () {
      // Rainsford analysed errors in the order of the fifth digit of a second,
      // and of the millimeter.
      // Note: some of these results exceed Rainsford's errors (if only
      // marginally) - worth investigating?

      const dms5 = Dms(type: DmsType.degMinSec, decimals: 5);
      const dms3 = Dms(type: DmsType.degMinSec, decimals: 3);

      const bessel1841 = Ellipsoid(
        id: 'Bessel1841',
        name: 'Bessel1841',
        a: 6377397.155,
        b: 6356078.962822,
        f: 1.0 / 299.15281285,
      );

      const intl1924 = Ellipsoid(
        id: 'Intl1924',
        name: 'Intl1924',
        a: 6378388.0,
        b: 6356911.946128,
        f: 1.0 / 297.0,
      );

      final testCases = [
        [
          bessel1841,
          '55°45′00.00000″N', // φ1
          '33°26′00.00000″S', // φ2
          '108°13′00.00000″', // L
          14110526.170, // s
          '096°36′08.79960″', // α1
          '137°52′22.01454″', // α2
          '33°26′00.00001″S, 108°13′00.00001″E', // a direct dest
          '96°36′08.800″', // a inverse brng1
          '137°52′22.015″', // a inverse brng2
        ],
        [
          intl1924,
          '37°19′54.95367″N', // φ1
          '26°07′42.83946″N', // φ2
          '041°28′35.50729″', // L
          4085966.703, // s
          '095°27′59.63089″', // α1
          '118°05′58.96161″', // α2
          '26°07′42.83945″N, 41°28′35.50730″E', // a direct dest
          '95°27′59.631″', // a inverse brng1
          '118°05′58.962″', // a inverse brng2
        ],
        [
          intl1924,
          '35°16′11.24862″N', // φ1
          '67°22′14.77638″N', // φ2
          '137°47′28.31435″', // L
          8084823.839, // s
          '015°44′23.74850″', // α1
          '144°55′39.92147″', // α2
          '67°22′14.77636″N, 137°47′28.31438″E', // a direct dest
          '15°44′23.748″', // a inverse brng1
          '144°55′39.921″', // a inverse brng2
        ],
        [
          intl1924,
          '1°00′00.00000″N', // φ1
          '00°59′53.83076″S', // φ2
          '179°17′48.02997″', // L
          19960000.000, // s
          '089°00′OO.00000″', // α1
          '091°00′06.11733″', // α2
          '0°59′53.83076″S, 179°17′48.02998″E', // a direct dest
          '88°59′59.999″', // a inverse brng1
          '91°00′06.118″', // a inverse brng2
        ],
        [
          intl1924,
          '01°00′00.00000″N', // φ1
          '01°01′15.18952″N', // φ2
          '179°46′17.84244″', // L
          19780006.558, // s
          '004°59′59.99995', // α1
          '174°59′59.88481″', // α2
          '1°01′15.18955″N, 179°46′17.84244″E', // a direct dest
          '5°00′00.000″', // a inverse brng1
          '174°59′59.885″', // a inverse brng2
        ],
      ];

      for (final t in testCases) {
        final ellipsoid = t[0] as Ellipsoid;
        final p1 = Geographic.parseDms(lat: t[1] as String, lon: '0');
        final v1 = p1.vincenty(ellipsoid: ellipsoid);
        final p2 =
            Geographic.parseDms(lat: t[2] as String, lon: t[3] as String);
        final s = t[4] as double;
        final alfa1 = dms5.parse(t[5] as String);
        //final alfa2 = dms5.parse(t[6] as String);
        final directRes = t[7] as String;
        final inverseBrng1 = t[8] as String;
        final inverseBrng2 = t[9] as String;

        expect(
          v1
              .destinationPoint(distance: s, bearing: alfa1)
              .latLonDms(format: dms5),
          directRes,
        );
        expect(v1.distanceTo(p2), closeTo(s, 0.009));
        expect(dms3.bearing(v1.initialBearingTo(p2)), inverseBrng1);
        expect(dms3.bearing(v1.finalBearingTo(p2)), inverseBrng2);
      }
    });

    test('UK', () {
      const le = Geographic(lat: 50.06632, lon: -5.71475);
      final leV = le.vincenty();
      const jog = Geographic(lat: 58.64402, lon: -3.07009);
      const dist = 969954.166;
      const brngInit = 9.1418775;
      const brngFinal = 11.2972204;

      expect(_fixed(leV.distanceTo(jog), 3), _fixed(dist, 3));
      expect(_fixed(leV.initialBearingTo(jog), 3), _fixed(brngInit, 3));
      expect(_fixed(leV.finalBearingTo(jog), 3), _fixed(brngFinal, 3));
      expect(
        leV.destinationPoint(distance: dist, bearing: brngInit).latLonDms(),
        jog.latLonDms(),
      );
      expect(
        _fixed(leV.finalBearingOn(distance: dist, bearing: brngInit), 3),
        _fixed(brngFinal, 3),
      );
      expect(
        leV.intermediatePointTo(jog, fraction: 0.0).latLonDms(),
        le.latLonDms(),
      );
      expect(
        leV.intermediatePointTo(jog, fraction: 1.0).latLonDms(),
        jog.latLonDms(),
      );
    });

    test('Geoscience Australia', () {
      // flindersPeak
      final p1 = Geographic.parseDms(
        lat: '37°57′03.72030″S',
        lon: '144°25′29.52440W″',
      );
      final v1 = p1.vincenty();
      // buninyong
      final p2 = Geographic.parseDms(
        lat: '37°39′10.15610″S',
        lon: '143°55′35.38390W″',
      );

      const dist = 54972.271;
      const azFwd = '306°52′05.37″';
      const azRev = '127°10′25.07″';

      const dms = Dms(type: DmsType.degMinSec, decimals: 2);

      expect(_fixed(v1.distanceTo(p2), 3), _fixed(dist, 3));
      expect(dms.bearing(v1.initialBearingTo(p2)), azFwd);
      expect(dms.bearing(v1.finalBearingTo(p2) - 180.0), azRev);
      expect(
        v1
            .destinationPoint(distance: dist, bearing: dms.parse(azFwd))
            .latLonDms(),
        p2.latLonDms(),
      );
      expect(
        dms.bearing(
          v1.finalBearingOn(distance: dist, bearing: dms.parse(azFwd)) - 180.0,
        ),
        azRev,
      );
    });

    test('Antipodal', () {
      const p1 = Geographic(lat: 0.0, lon: 0.0);
      final v1 = p1.vincenty();
      const p2 = Geographic(lat: 90.0, lon: 0.0);
      final v2 = p2.vincenty();
      const p3 = Geographic(lat: 0.5, lon: 179.5);
      const p4 = Geographic(lat: 0.5, lon: 179.7);
      const p5 = Geographic(lat: 0.0, lon: 180.0);
      const p6 = Geographic(lat: -90.0, lon: 0.0);

      // near-antipodal distance
      expect(_fixed(v1.distanceTo(p3), 3), '19936288.579');
      // antipodal convergence failure dist
      expect(v1.distanceTo(p4), isNaN);
      // antipodal convergence failure brng i
      expect(v1.initialBearingTo(p4), isNaN);
      // antipodal convergence failure brng f
      expect(v1.finalBearingTo(p4), isNaN);
      // antipodal distance equatorial
      expect(_fixed(v1.distanceTo(p5), 3), _fixed(circMeridional / 2, 3));
      // antipodal brng equatorial
      expect(v1.initialBearingTo(p5), isZero);
      // antipodal distance meridional
      expect(_fixed(v2.distanceTo(p6), 3), _fixed(circMeridional / 2, 3));
      // antipodal brng meridional
      expect(v2.initialBearingTo(p6), isZero);
    });

    test('small dist (to 2mm)', () {
      const p1 = Geographic(lat: 0.0, lon: 0.0);
      final v1 = p1.vincenty();

      // 1e-5°
      const p2 = Geographic(lat: 0.000010000, lon: 0.000010000);
      expect(_fixed(v1.distanceTo(p2), 3), '1.569');
      // 1e-6°
      const p3 = Geographic(lat: 0.000001000, lon: 0.000001000);
      expect(_fixed(v1.distanceTo(p3), 3), '0.157');
      // 1e-7°
      const p4 = Geographic(lat: 0.000000100, lon: 0.000000100);
      expect(_fixed(v1.distanceTo(p4), 3), '0.016');
      // 1e-8°
      const p5 = Geographic(lat: 0.000000010, lon: 0.000000010);
      expect(_fixed(v1.distanceTo(p5), 3), '0.002');
      // 1e-9°
      const p6 = Geographic(lat: 0.000000001, lon: 0.000000001);
      expect(_fixed(v1.distanceTo(p6), 3), '0.000');
    });

    test('coincident', () {
      const p1 = Geographic(lat: 50.06632, lon: -5.71475);
      final v1 = p1.vincenty();
      const p2 = Geographic(lat: 0.0, lon: 0.0);
      final v2 = p2.vincenty();
      const p3 = Geographic(lat: 0.0, lon: 1.0);

      // inverse coincident distance
      expect(v1.distanceTo(p1), isZero);
      // inverse coincident initial bearing
      expect(v1.initialBearingTo(p1), isNaN);
      // inverse coincident final bearing
      expect(v1.finalBearingTo(p1), isNaN);
      // inverse equatorial distance
      expect(_fixed(v2.distanceTo(p3), 3), '111319.491');
      // direct coincident destination
      expect(
        v1.destinationPoint(distance: 0.0, bearing: 0.0).toString(),
        p1.toString(),
      );
    });

    test('crossing antimeridian', () {
      const p1 = Geographic(lat: 30, lon: 120);
      final v1 = p1.vincenty();
      const p2 = Geographic(lat: 30, lon: -120);
      expect(v1.distanceTo(p2), closeTo(10825924.089, 0.0001));
    });

    test('quadrants', () {
      final testCases = [
        ['Q1 a', 30.0, 30.0, 60.0, 60.0],
        ['Q1 b', 60.0, 60.0, 30.0, 30.0],
        ['Q1 c', 30.0, 60.0, 60.0, 30.0],
        ['Q1 d', 60.0, 30.0, 30.0, 60.0],
        ['Q2 a', 30.0, -30.0, 60.0, -60.0],
        ['Q2 b', 60.0, -60.0, 30.0, -30.0],
        ['Q2 c', 30.0, -60.0, 60.0, -30.0],
        ['Q2 d', 60.0, -30.0, 30.0, -60.0],
        ['Q3 a', -30.0, -30.0, -60.0, -60.0],
        ['Q3 b', -60.0, -60.0, -30.0, -30.0],
        ['Q3 c', -30.0, -60.0, -60.0, -30.0],
        ['Q3 d', -60.0, -30.0, -30.0, -60.0],
        ['Q4 a', -30.0, 30.0, -60.0, 60.0],
        ['Q4 b', -60.0, 60.0, -30.0, 30.0],
        ['Q4 c', -30.0, 60.0, -60.0, 30.0],
        ['Q4 d', -60.0, 30.0, -30.0, 60.0],
      ];
      for (final t in testCases) {
        final v1 =
            Geographic(lat: t[1] as double, lon: t[2] as double).vincenty();
        final p2 = Geographic(lat: t[3] as double, lon: t[4] as double);
        expect(v1.distanceTo(p2), closeTo(4015703.021, 0.0001));
      }
    });

    test('convergence', () {
      // vincenty antipodal λ > π
      expect(
        const Geographic(lat: 0.0, lon: 0.0)
            .vincenty()
            .distanceTo(const Geographic(lat: 0.5, lon: 179.7)),
        isNaN,
      );
      // vincenty antipodal convergence
      expect(
        const Geographic(lat: 5.0, lon: 0.0)
            .vincenty()
            .distanceTo(const Geographic(lat: -5.1, lon: 179.4)),
        isNaN,
      );
    });

    test('OSGB36 datum using Airy1830 ellipsoid', () {
      const ellipsoid = Ellipsoid(
        id: 'Airy1830',
        name: 'Airy1830',
        a: 6377563.396,
        b: 6356256.909,
        f: 1.0 / 299.3249646,
      );

      const le = Geographic(lat: 50.065716, lon: -5.713824); // in OSGB-36
      final leV = le.vincenty(ellipsoid: ellipsoid);
      const jog = Geographic(lat: 58.644399, lon: -3.068521); // in OSGB-36

      // 27.848m more than on WGS-84 ellipsoid; Airy1830 has a smaller
      // flattening, hence larger distance at higher latitudes;
      const dist = 969982.014;
      const brngInit = 9.1428517;

      expect(_fixed(leV.distanceTo(jog), 3), _fixed(dist, 3));
      expect(_fixed(leV.initialBearingTo(jog), 3), _fixed(brngInit, 3));
      expect(
        leV.destinationPoint(distance: dist, bearing: brngInit).latLonDms(),
        jog.latLonDms(),
      );
    });
  });
}
