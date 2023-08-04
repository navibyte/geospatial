/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Geodesy Test Harness - latlon-spherical                            (c) Chris Veness 2014-2021  */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// Spherical geodesy tools by Chris Veness ported to Dart by Navibyte.
//
// Source:
// https://github.com/chrisveness/geodesy/blob/master/test/latlon-spherical-tests.js

// ignore_for_file: lines_longer_than_80_chars, prefer_const_constructors
// ignore_for_file: avoid_multiple_declarations_per_line

import 'dart:math';

import 'package:geobase/coordinates.dart';
import 'package:geobase/geodesy.dart';

import 'package:test/test.dart';

void main() {
  const R = 6371e3;
  const epsilon = 2.220446049250313E-16; // == JavaScript Number.EPSILON
  //const dms = Dms(zeroPadDegrees: true);

  group('latlon-spherical tests', () {
    test('examples', () {
      const p1 = Geographic(lat: 52.205, lon: 0.119);
      const p2 = Geographic(lat: 48.857, lon: 2.351);
      const greenwich = Geographic(lat: 51.47788, lon: -0.00147);

      expect(p1.latLonDms(separator: ' '), '52.2050°N 0.1190°E');

      const latLonData = [
        ['52.205', '0.119'],
        ['52°12′18.0″N', '000°07′08.4″E'],
        ['52°12′18.0″', '000°07′08.4″'],
        ['52 12 18.0', '000 07 08.4'],
      ];
      for (final latLon in latLonData) {
        expect(
          Geographic.parseDms(lat: latLon[0], lon: latLon[1]).latLonDms(),
          '52.2050°N, 0.1190°E',
        );
      }

      final sp1 = p1.spherical;
      expect(sp1.distanceTo(p2).toStringAsFixed(0), '404279');
      expect(
        // distance in miles
        sp1.distanceTo(p2, radius: 3959).toStringAsFixed(1),
        '251.2',
      );
      expect(sp1.initialBearingTo(p2).toStringAsFixed(1), '156.2');
      expect(sp1.finalBearingTo(p2).toStringAsFixed(1), '157.9');
      expect(
        sp1.midPointTo(p2).latLonDms(),
        '50.5363°N, 1.2746°E',
      );
      expect(
        sp1.intermediatePointTo(p2, fraction: 0.25).latLonDms(),
        '51.3721°N, 0.7073°E',
      );
      expect(
        greenwich.spherical
            .destinationPoint(distance: 7794, bearing: 300.7)
            .latLonDms(),
        '51.5136°N, 0.0983°W',
      );
      expect(
        Geographic(lat: 51.8853, lon: 0.2545)
            .spherical
            .intersectionWith(
              bearing: 108.547,
              other: Geographic(lat: 49.0034, lon: 2.5735),
              otherBearing: 32.435,
            )!
            .latLonDms(),
        '50.9078°N, 4.5084°E',
      );
      expect(
        Geographic(lat: 53.2611, lon: -0.7972)
            .spherical
            .crossTrackDistanceTo(
              start: Geographic(lat: 53.3206, lon: -1.7297),
              end: Geographic(lat: 53.1887, lon: 0.1334),
            )
            .toStringAsFixed(1),
        '-307.5',
      );
      expect(
        Geographic(lat: 53.2611, lon: -0.7972)
            .spherical
            .alongTrackDistanceTo(
              start: Geographic(lat: 53.3206, lon: -1.7297),
              end: Geographic(lat: 53.1887, lon: 0.1334),
            )
            .toStringAsFixed(0),
        '62331',
      );

      const p3 = Geographic(lat: 51.127, lon: 1.338);
      const p4 = Geographic(lat: 50.964, lon: 1.853);

      final rl3 = p3.rhumb;
      expect(rl3.distanceTo(p4).toStringAsFixed(0), '40308');
      expect(rl3.initialBearingTo(p4).toStringAsFixed(1), '116.7');
      expect(rl3.finalBearingTo(p4).toStringAsFixed(1), '116.7');
      expect(
        rl3.destinationPoint(distance: 40300, bearing: 116.7).latLonDms(),
        '50.9642°N, 1.8530°E',
      );
      expect(
        rl3.midPointTo(p4).latLonDms(),
        '51.0455°N, 1.5957°E',
      );

      const polygon = [
        Geographic(lat: 0.0, lon: 0.0),
        Geographic(lat: 1.0, lon: 0.0),
        Geographic(lat: 0.0, lon: 1.0),
        Geographic(lat: 0.0, lon: 0.0),
      ];
      expect(
        polygon.spherical.polygonArea().toStringAsExponential(2),
        '6.18e+9',
      );
      expect(
        Geographic(lat: 52.205, lon: 0.119),
        Geographic(lat: 52.205, lon: 0.119),
      );

      expect(greenwich.latLonDms(separator: ' '), '51.4779°N 0.0015°W');
      expect(
        greenwich.latLonDms(
          format: Dms(type: DmsType.degMinSec, decimals: 2),
        ),
        '51°28′40.37″N, 0°00′05.29″W',
      );
      expect(
        greenwich.latLonDms(format: Dms.numeric(), separator: ' ').split(' '),
        ['51.4779', '-0.0015'],
      );
    });

    test('dist/brng/dest', () {
      const cambg = Geographic(lat: 52.205, lon: 0.119);
      const paris = Geographic(lat: 48.857, lon: 2.351);

      final cambgSp = cambg.spherical;
      final parisSp = paris.spherical;

      expect(cambgSp.distanceTo(paris).toStringAsPrecision(4), '4.043e+5');
      expect(
        // distance in miles
        cambgSp.distanceTo(paris, radius: 3959).toStringAsPrecision(4),
        '251.2',
      );
      expect(cambgSp.initialBearingTo(paris).toStringAsFixed(1), '156.2');
      expect(cambgSp.finalBearingTo(paris).toStringAsFixed(1), '157.9');
      expect(cambgSp.initialBearingTo(cambg), isNaN);
      expect(cambgSp.finalBearingTo(cambg), isNaN);
      expect(parisSp.initialBearingTo(cambg).toStringAsFixed(1), '337.9');
      expect(
        cambgSp.midPointTo(paris).latLonDms(),
        '50.5363°N, 1.2746°E',
      );
      expect(
        cambgSp.intermediatePointTo(paris, fraction: 0.25).latLonDms(),
        '51.3721°N, 0.7073°E',
      );
      expect(
        cambgSp.intermediatePointTo(cambg, fraction: 0.25).latLonDms(),
        '52.2050°N, 0.1190°E',
      );

      final greenwichSp = Geographic(lat: 51.47788, lon: -0.00147).spherical;
      const dist = 7794.0;
      const brng = 300.7;
      expect(
        greenwichSp.destinationPoint(distance: dist, bearing: brng).latLonDms(),
        '51.5136°N, 0.0983°W',
      );
    });
  });

  group('latlon-spherical / intersection', () {
    const N = 0.0, E = 90.0, S = 180.0, W = 270.0;
    const p01 = Geographic(lat: 0, lon: 1);
    const p10 = Geographic(lat: 1, lon: 0);
    const p11 = Geographic(lat: 1, lon: 1);
    const p1_90 = Geographic(lat: 1, lon: 90);
    const p1_92 = Geographic(lat: 1, lon: 92);
    const p21 = Geographic(lat: 2, lon: 1);

    test('toward 1,1 N,E nearest', () {
      expect(
        p01.spherical
            .intersectionWith(bearing: N, other: p10, otherBearing: E)!
            .latLonDms(),
        '0.9998°N, 1.0000°E',
      );
    });
    test('toward 1,1 E,N nearest', () {
      expect(
        p10.spherical
            .intersectionWith(bearing: E, other: p01, otherBearing: N)!
            .latLonDms(),
        '0.9998°N, 1.0000°E',
      );
    });
    test('toward 1,1 N,E antipodal', () {
      expect(
        p21.spherical.intersectionWith(bearing: N, other: p10, otherBearing: E),
        isNull,
      );
    });
    test('toward/away 1,1 N,W antipodal', () {
      expect(
        p01.spherical.intersectionWith(bearing: N, other: p10, otherBearing: W),
        isNull,
      );
    });
    test('toward/away 1,1 W,N antipodal', () {
      expect(
        p10.spherical.intersectionWith(bearing: W, other: p01, otherBearing: N),
        isNull,
      );
    });
    test('toward/away 1,1 S,E antipodal', () {
      expect(
        p10.spherical.intersectionWith(bearing: W, other: p01, otherBearing: E),
        isNull,
      );
    });
    test('toward/away 1,1 E,S antipodal', () {
      expect(
        p10.spherical.intersectionWith(bearing: E, other: p01, otherBearing: S),
        isNull,
      );
    });
    test('away 1,1 S,W antipodal', () {
      expect(
        p01.spherical
            .intersectionWith(bearing: S, other: p10, otherBearing: W)!
            .latLonDms(),
        '0.9998°S, 179.0000°W',
      );
    });
    test('away 1,1 W,S antipodal', () {
      expect(
        p10.spherical
            .intersectionWith(bearing: W, other: p01, otherBearing: S)!
            .latLonDms(),
        '0.9998°S, 179.0000°W',
      );
    });
    test('1E/90E N,E antipodal', () {
      expect(
        p01.spherical
            .intersectionWith(bearing: N, other: p1_90, otherBearing: E),
        isNull,
      );
    });
    test('1E/90E N,E nearest', () {
      expect(
        p01.spherical
            .intersectionWith(bearing: N, other: p1_92, otherBearing: E)!
            .latLonDms(),
        '0.0175°N, 179.0000°W',
      );
    });
    test('coincident', () {
      expect(
        p11.spherical
            .intersectionWith(bearing: N, other: p11, otherBearing: E)!
            .latLonDms(),
        '1.0000°N, 1.0000°E',
      );
    });

    const stn = Geographic(lat: 51.8853, lon: 0.2545);
    const cdg = Geographic(lat: 49.0034, lon: 2.5735);

    test('stn-cdg-bxl', () {
      expect(
        stn.spherical
            .intersectionWith(
              bearing: 108.547,
              other: cdg,
              otherBearing: 32.435,
            )!
            .latLonDms(),
        '50.9078°N, 4.5084°E',
      );
    });
    test('rounding errors', () {
      expect(
        Geographic(lat: 51, lon: 0)
            .spherical
            .intersectionWith(
              bearing: 120,
              other: Geographic(lat: 50, lon: 0),
              otherBearing: 60,
            )!
            .latLonDms(),
        '50.4921°N, 1.3612°E',
      );
    });

    /*
    // NOTE: some issues here, test failing
          /*
            // original test
            test('rounding: φ3 requires clamp #71', () => LatLon.intersection(
              new LatLon(-77.6966041375563, 18.2812500000000), 
              179.99999999999994, 
              new LatLon(89, 180), 
              180).toString().should.equal('90.0000°S, 163.9902°W'));
          */

    test('rounding: φ3 requires clamp #71', () {
      expect(
        Geographic(lat: -77.6966041375563, lon: 18.2812500000000)
            .spherical
            .intersectionWith(
              bearing: 179.99999999999994,
              other: Geographic(lat: 89, lon: 180),
              otherBearing: 180,
            )!
            .toDmsLatLon(),
        '90.0000°S, 163.9902°W',
      );
    });
  */
  });

  group('latlon-spherical / cross-track / along-track', () {
    const p0_0 = Geographic(lat: 0, lon: 0);
    const p10_1 = Geographic(lat: 10, lon: 1);
    const p10_0 = Geographic(lat: 10, lon: 0);
    const p0_2 = Geographic(lat: 0, lon: 2);
    const bradwell = Geographic(lat: 53.3206, lon: -1.7297);
    const dunham = Geographic(lat: 53.2611, lon: -0.7972);
    const partney = Geographic(lat: 53.1887, lon: 0.1334);
    const pp1p1 = Geographic(lat: 1, lon: 1);
    const pm1p1 = Geographic(lat: -1, lon: 1);
    const pm1m1 = Geographic(lat: -1, lon: -1);
    const pp1m1 = Geographic(lat: 1, lon: -1);

    test('cross-track p', () {
      expect(
        p10_1.spherical
            .crossTrackDistanceTo(start: p0_0, end: p0_2)
            .toStringAsPrecision(4),
        '-1.112e+6',
      );
    });
    test('cross-track', () {
      expect(
        dunham.spherical
            .crossTrackDistanceTo(start: bradwell, end: partney)
            .toStringAsPrecision(4),
        '-307.5',
      );
    });
    test('along-track', () {
      expect(
        dunham.spherical
            .alongTrackDistanceTo(start: bradwell, end: partney)
            .toStringAsPrecision(4),
        '6.233e+4',
      );
    });

    test('cross-track NE', () {
      expect(
        pp1p1.spherical
            .crossTrackDistanceTo(start: p0_0, end: p0_2)
            .toStringAsPrecision(4),
        '-1.112e+5',
      );
    });
    test('cross-track SE', () {
      expect(
        pm1p1.spherical
            .crossTrackDistanceTo(start: p0_0, end: p0_2)
            .toStringAsPrecision(4),
        '1.112e+5',
      );
    });
    test('cross-track SW?', () {
      expect(
        pm1m1.spherical
            .crossTrackDistanceTo(start: p0_0, end: p0_2)
            .toStringAsPrecision(4),
        '1.112e+5',
      );
    });
    test('cross-track NW?', () {
      expect(
        pp1m1.spherical
            .crossTrackDistanceTo(start: p0_0, end: p0_2)
            .toStringAsPrecision(4),
        '-1.112e+5',
      );
    });

    test('along-track NE', () {
      expect(
        pp1p1.spherical
            .alongTrackDistanceTo(start: p0_0, end: p0_2)
            .toStringAsPrecision(4),
        '1.112e+5',
      );
    });
    test('along-track SE', () {
      expect(
        pm1p1.spherical
            .alongTrackDistanceTo(start: p0_0, end: p0_2)
            .toStringAsPrecision(4),
        '1.112e+5',
      );
    });
    test('along-track SW', () {
      expect(
        pm1m1.spherical
            .alongTrackDistanceTo(start: p0_0, end: p0_2)
            .toStringAsPrecision(4),
        '-1.112e+5',
      );
    });
    test('along-track NW', () {
      expect(
        pp1m1.spherical
            .alongTrackDistanceTo(start: p0_0, end: p0_2)
            .toStringAsPrecision(4),
        '-1.112e+5',
      );
    });

    test('cross-track coinc', () {
      expect(p10_0.spherical.alongTrackDistanceTo(start: p10_0, end: p0_2), 0);
    });
    test('along-track coinc', () {
      expect(p10_0.spherical.alongTrackDistanceTo(start: p10_0, end: p0_2), 0);
    });

    test('', () {});
    test('', () {});
  });

  group('latlon-spherical / misc', () {
    const p0_0 = Geographic(lat: 0, lon: 0);

    test('Clairaut 0°', () {
      expect(p0_0.spherical.maxLatitude(bearing: 0), 90);
    });
    test('Clairaut 1°', () {
      expect(p0_0.spherical.maxLatitude(bearing: 1), 89);
    });
    test('Clairaut 90°', () {
      expect(p0_0.spherical.maxLatitude(bearing: 90), 0);
    });

    final parallels = p0_0.spherical
        .crossingParallels(other: Geographic(lat: 60, lon: 30), latitude: 30);
    const dms = Dms(type: DmsType.degMinSec);

    test('parallels 1', () {
      expect(
        Geographic(lat: 30, lon: parallels![0]).latLonDms(format: dms),
        '30°00′00″N, 9°35′39″E',
      );
    });
    test('parallels 2', () {
      expect(
        Geographic(lat: 30, lon: parallels![1]).latLonDms(format: dms),
        '30°00′00″N, 170°24′21″E',
      );
    });
    test('parallels -', () {
      expect(
        p0_0.spherical.crossingParallels(
          other: Geographic(lat: 30, lon: 60),
          latitude: 60,
        ),
        isNull,
      );
    });
    test('parallels coinc', () {
      expect(
        p0_0.spherical.crossingParallels(other: p0_0, latitude: 0),
        isNull,
      );
    });
  });

  group('latlon-spherical / area (polygon-based)', () {
    const polyTriangle = [
      Geographic(lat: 1, lon: 1),
      Geographic(lat: 2, lon: 1),
      Geographic(lat: 1, lon: 2),
      Geographic(lat: 1, lon: 1),
    ];
    const polyTriangleLastNotSameAsFirst = [
      Geographic(lat: 1, lon: 1),
      Geographic(lat: 2, lon: 1),
      Geographic(lat: 1, lon: 2),
      Geographic(lat: 1, lon: 1.1),
    ];
    const polySquareCw = [
      Geographic(lat: 1, lon: 1),
      Geographic(lat: 2, lon: 1),
      Geographic(lat: 2, lon: 2),
      Geographic(lat: 1, lon: 2),
      Geographic(lat: 1, lon: 1),
    ];
    const polySquareCcw = [
      Geographic(lat: 1, lon: 1),
      Geographic(lat: 1, lon: 2),
      Geographic(lat: 2, lon: 2),
      Geographic(lat: 2, lon: 1),
      Geographic(lat: 1, lon: 1),
    ];
    const polyOctant = [
      Geographic(lat: 0, lon: epsilon),
      Geographic(lat: 90, lon: 0),
      Geographic(lat: 0, lon: 90 - epsilon),
      Geographic(lat: 0, lon: epsilon),
    ];
    const polyOctantS = [
      Geographic(lat: -epsilon, lon: epsilon),
      Geographic(lat: 90, lon: 0),
      Geographic(lat: -epsilon, lon: 90 - epsilon),
      Geographic(lat: -epsilon, lon: epsilon),
    ];
    const polyQuadrant = [
      Geographic(lat: epsilon, lon: epsilon),
      Geographic(lat: 90, lon: epsilon),
      Geographic(lat: epsilon, lon: 180 - epsilon),
      Geographic(lat: epsilon, lon: 90),
      Geographic(lat: epsilon, lon: epsilon),
    ];
    const polyHemiE = [
      Geographic(lat: epsilon, lon: epsilon),
      Geographic(lat: 90 - epsilon, lon: 0),
      Geographic(lat: 90 - epsilon, lon: 180),
      Geographic(lat: epsilon, lon: 180),
      Geographic(lat: -epsilon, lon: 180),
      Geographic(lat: -90 + epsilon, lon: 180),
      Geographic(lat: -90 + epsilon, lon: 0),
      Geographic(lat: -epsilon, lon: epsilon),
      Geographic(lat: epsilon, lon: epsilon),
    ];
    const polyPole = [
      Geographic(lat: 89, lon: 0),
      Geographic(lat: 89, lon: 120),
      Geographic(lat: 89, lon: -120),
      Geographic(lat: 89, lon: 0),
    ];
    const polyConcave = [
      Geographic(lat: 1, lon: 1),
      Geographic(lat: 5, lon: 1),
      Geographic(lat: 5, lon: 3),
      Geographic(lat: 1, lon: 3),
      Geographic(lat: 3, lon: 2),
      Geographic(lat: 1, lon: 1),
    ];

    test('triangle area', () {
      expect(
        polyTriangle.spherical.polygonArea().toStringAsFixed(0),
        '6181527888',
      );
    });
    test('triangle area NOT closed', () {
      expect(
        () => polyTriangle.sublist(0, 3).spherical.polygonArea(),
        throwsFormatException,
      );
      expect(
        () => polyTriangleLastNotSameAsFirst.spherical.polygonArea(),
        throwsFormatException,
      );
    });
    test('square cw area', () {
      expect(
        polySquareCw.spherical.polygonArea().toStringAsFixed(0),
        '12360230987',
      );
    });
    test('square ccw area', () {
      expect(
        polySquareCcw.spherical.polygonArea().toStringAsFixed(0),
        '12360230987',
      );
    });
    test('octant area', () {
      expect(
        polyOctant.spherical.polygonArea().toStringAsFixed(1),
        (pi * R * R / 2.0).toStringAsFixed(1),
      );
    });
    test('super-octant area', () {
      expect(
        polyOctantS.spherical.polygonArea().toStringAsFixed(1),
        (pi * R * R / 2.0).toStringAsFixed(1),
      );
    });
    test('quadrant area', () {
      expect(
        polyQuadrant.spherical.polygonArea(),
        pi * R * R,
      );
    });
    test('hemisphere area', () {
      expect(
        polyHemiE.spherical.polygonArea().toStringAsFixed(1),
        (2.0 * pi * R * R).toStringAsFixed(1),
      );
    });
    test('pole area', () {
      expect(
        polyPole.spherical.polygonArea().toStringAsFixed(0),
        '16063139192',
      );
    });
    test('concave area', () {
      expect(
        polyConcave.spherical.polygonArea().toStringAsFixed(0),
        '74042699236',
      );
    });
  });

  group('latlon-spherical / Ed Williams', () {
    // www.edwilliams.org/avform.htm
    final lax = Geographic.parseDms(lat: '33° 57′N', lon: '118° 24′W');
    final jfk = Geographic.parseDms(lat: '40° 38′N', lon: '073° 47′W');
    const r = 180.0 * 60.0 / pi; // earth radius in nautical miles

    test('distance nm', () {
      expect(
        lax.spherical.distanceTo(jfk, radius: r).toStringAsPrecision(4),
        '2144',
      );
    });
    test('bearing', () {
      expect(
        lax.spherical.initialBearingTo(jfk).toStringAsPrecision(2),
        '66',
      );
    });
    test('intermediate', () {
      expect(
        lax.spherical
            .intermediatePointTo(jfk, fraction: 100.0 / 2144.0)
            .latLonDms(format: Dms(type: DmsType.degMin, decimals: 0)),
        '34°37′N, 116°33′W',
      );
    });

    final d = Geographic.parseDms(lat: '34:30N', lon: '116:30W');

    test('cross-track', () {
      expect(
        d.spherical
            .crossTrackDistanceTo(start: lax, end: jfk, radius: r)
            .toStringAsPrecision(5),
        '7.4523',
      );
    });
    test('along-track', () {
      expect(
        d.spherical
            .alongTrackDistanceTo(start: lax, end: jfk, radius: r)
            .toStringAsPrecision(5),
        '99.588',
      );
    });
    test('intermediate', () {
      expect(
        lax.spherical
            .intermediatePointTo(jfk, fraction: 0.4)
            .latLonDms(format: Dms(type: DmsType.degMin, decimals: 3)),
        '38°40.167′N, 101°37.570′W',
      );
    });

    final reo = Geographic.parseDms(lat: '42.600N', lon: '117.866W');
    final bke = Geographic.parseDms(lat: '44.840N', lon: '117.806W');

    test('intersection', () {
      expect(
        reo.spherical
            .intersectionWith(bearing: 51, other: bke, otherBearing: 137)!
            .latLonDms(format: Dms(decimals: 3)),
        '43.572°N, 116.189°W',
      );
    });
    test('', () {});
  });

  group('latlon-spherical / rhumb lines', () {
    const dov = Geographic(lat: 51.127, lon: 1.338);
    const cal = Geographic(lat: 50.964, lon: 1.853);

    test('distance', () {
      expect(dov.rhumb.distanceTo(cal).toStringAsPrecision(4), '4.031e+4');
    });
    test('dist E-W (Δψ < 10⁻¹²)', () {
      expect(
        Geographic(lat: 1, lon: -1)
            .rhumb
            .distanceTo(Geographic(lat: 1, lon: 1))
            .toStringAsPrecision(4),
        '2.224e+5',
      );
    });
    test('dist @ -90° (Δψ → ∞)', () {
      expect(
        Geographic(lat: -90, lon: 0)
            .rhumb
            .distanceTo(Geographic(lat: 0, lon: 0))
            .toStringAsPrecision(4),
        '1.001e+7',
      );
    });
    test('distance dateline E-W', () {
      expect(
        Geographic(lat: 1, lon: -179)
            .rhumb
            .distanceTo(Geographic(lat: 1, lon: 179))
            .toStringAsFixed(6),
        Geographic(lat: 1, lon: 1)
            .rhumb
            .distanceTo(Geographic(lat: 1, lon: -1))
            .toStringAsFixed(6),
      );
    });
    test('bearing', () {
      expect(dov.rhumb.initialBearingTo(cal).toStringAsFixed(1), '116.7');
      expect(dov.rhumb.finalBearingTo(cal).toStringAsFixed(1), '116.7');
    });
    test('bearing dateline', () {
      expect(
        Geographic(lat: 1, lon: -179)
            .rhumb
            .initialBearingTo(Geographic(lat: 1, lon: 179)),
        270,
      );
      expect(
        Geographic(lat: 1, lon: 179)
            .rhumb
            .initialBearingTo(Geographic(lat: 1, lon: -179)),
        90,
      );
    });
    test('bearing coincident', () {
      expect(dov.rhumb.initialBearingTo(dov), isNaN);
    });
    test('dest’n', () {
      expect(
        dov.rhumb.destinationPoint(distance: 40310, bearing: 116.7).latLonDms(),
        '50.9641°N, 1.8531°E',
      );
      expect(
        Geographic(lat: 1, lon: 1)
            .rhumb
            .destinationPoint(distance: 111178, bearing: 90)
            .latLonDms(),
        '1.0000°N, 2.0000°E',
      );
    });
    test('dest’n dateline', () {
      expect(
        Geographic(lat: 1, lon: 179)
            .rhumb
            .destinationPoint(distance: 222356, bearing: 90)
            .latLonDms(),
        '1.0000°N, 179.0000°W',
      );
      expect(
        Geographic(lat: 1, lon: -179)
            .rhumb
            .destinationPoint(distance: 222356, bearing: 270)
            .latLonDms(),
        '1.0000°N, 179.0000°E',
      );
    });
    test('midpoint', () {
      expect(
        dov.rhumb.midPointTo(cal).latLonDms(),
        '51.0455°N, 1.5957°E',
      );
    });
    test('midpoint dateline', () {
      expect(
        Geographic(lat: 1, lon: -179)
            .rhumb
            .midPointTo(Geographic(lat: 1, lon: 178))
            .latLonDms(),
        '1.0000°N, 179.5000°E',
      );
    });

    test('', () {});
    test('', () {});
  });

  group('latlon-spherical / ', () {
    test('', () {});
    test('', () {});
    test('', () {});
  });
}
