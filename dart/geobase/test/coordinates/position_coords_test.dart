// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: unrelated_type_equality_checks, prefer_const_declarations

import 'package:geobase/coordinates.dart';

import 'package:test/test.dart';

void main() {
  group('Position coords as iterable', () {
    test('Coordinate values as iterable', () {
      // xyz and xym coordinates
      const xyzData = [15.0, 30.1, 45.2];
      const xymData = [15.0, 30.1, 60.3];

      // positions from data
      final xyzPos = xyzData.xyz;
      final xymPos = xymData.xym;

      // positions as lists equals to their representive iterable representation
      expect(xyzPos.values, xyzData);
      expect(xymPos.values, xymData);

      // positions equals to their representive iterable representation
      expect(xyzPos.values, xyzData);
      expect(xymPos.values, xymData);

      // but not vice versa, as expected
      expect(xyzPos.values, isNot(xymData));
      expect(xymPos.values, isNot(xyzData));

      // then we create "XYZ" position from "XYM" data
      final xyzPosFromXym = xymData.xyz;

      // xym and xyz positions from same data are not equal
      expect(xymPos == xyzPosFromXym, false);
      expect(xyzPosFromXym == xymPos, false);

      // however following test clause would fail, because "isNot" matcher
      // tests xymPos vs xyzPosFromXym by iterating items (here both has
      // data [15, 30, 60], but value 60 means M or Z for different positions)
      // expect(xymPos, isNot(xyzPosFromXym));

      // testing equality (Projected -> List) using == operatator of Projected
      expect(xymPos == xymData, false);
      expect(xyzPosFromXym == xymData, false);

      // testing equality (List -> Projected) using == operatator of List
      // List doc: "Lists are, by default, only equal to themselves. Even if
      //           [other] is also a list, the equality comparison does not
      //           compare the elements of the two lists."
      expect(xymData == xymPos, false);
      expect(xymData == xyzPosFromXym, false);

      // expect matches by indidually iterating, so there test are ok
      expect(xymData, xymPos.values);
      expect(xymData, xyzPosFromXym.values);

      // testing by values (xymPos vs xyzPos)
      expect(xymPos[0], xyzPos[0]);
      expect(xymPos[1], xyzPos[1]);
      expect(xymPos[2], isNot(xyzPos[2]));
      expect(xymPos.values.elementAt(0), xyzPos.values.elementAt(0));
      expect(xymPos.values.elementAt(1), xyzPos.values.elementAt(1));
      expect(xymPos.values.elementAt(2), isNot(xyzPos.values.elementAt(2)));
      expect(xymPos.x, xyzPos.x);
      expect(xymPos.y, xyzPos.y);
      expect(xymPos.z, isNot(xyzPos.z));
      expect(xymPos.m, isNot(xyzPos.m));
      expect(xymPos.optM, isNotNull);
      expect(xymPos.optZ, isNull);
      expect(xyzPos.optM, isNull);
      expect(xyzPos.optZ, isNotNull);

      // testing by values (xymPos vs xyzPosFromXym)
      expect(xymPos[0], xyzPosFromXym[0]);
      expect(xymPos[1], xyzPosFromXym[1]);
      expect(xymPos[2], xyzPosFromXym[2]);
      expect(xymPos.values.elementAt(0), xyzPosFromXym.values.elementAt(0));
      expect(xymPos.values.elementAt(1), xyzPosFromXym.values.elementAt(1));
      expect(xymPos.values.elementAt(2), xyzPosFromXym.values.elementAt(2));
      expect(xymPos.x, xyzPosFromXym.x);
      expect(xymPos.y, xyzPosFromXym.y);
      expect(xymPos.z, isNot(xyzPosFromXym.z));
      expect(xymPos.m, isNot(xyzPosFromXym.m));
      expect(xymPos.optM, isNotNull);
      expect(xymPos.optZ, isNull);
      expect(xyzPosFromXym.optM, isNull);
      expect(xyzPosFromXym.optZ, isNotNull);
    });

    test('Coords from extension', () {
      const xyData = [15.0, 30.1];
      const xyzData = [15.0, 30.1, 45.2];
      const xymData = [15.0, 30.1, 60.3];
      const xyzmData = [15.0, 30.1, 45.2, 60.3];

      expect(Position.view(xyData), Projected.build(xyData));
      expect(Position.view(xyData).values, Projected.build(xyData).values);
      expect(
        Position.view(xyzData, type: Coords.xyz),
        Projected.build(xyzData),
      );
      expect(
        Position.view(xyzData, type: Coords.xyz),
        Projected.build(xyzData, type: Coords.xyz),
      );
      expect(
        Position.view(xymData, type: Coords.xym),
        Projected.build(xymData, type: Coords.xym),
      );
      expect(
        Position.view(xyzmData, type: Coords.xyzm),
        Projected.build(xyzmData, type: Coords.xyzm),
      );
    });

    test('Coordinate access and factories', () {
      final p1 = [1.0, 2.0].xy;
      final p2 = [1.0, 2.0, 3.0].xyz;
      final p3 = [1.0, 2.0, 4.0].xym;
      final p4 = [1.0, 2.0, 3.0, 4.0].xyzm;
      expect([p1.x, p1.y], p1.values);
      expect([p2.x, p2.y, p2.z], p2.values);
      expect([p3.x, p3.y, p3.m], p3.values);
      expect([p4.x, p4.y, p4.z, p4.m], p4.values);
      expect([p1.x, p1.y, 0, 0], [p1[0], p1[1], p1[2], p1[3]]);
      expect([p2.x, p2.y, p2.z, 0], [p2[0], p2[1], p2[2], p2[3]]);
      expect([p3.x, p3.y, p3.m, 0], [p3[0], p3[1], p3[2], p3[3]]);
      expect([p4.x, p4.y, p4.z, p4.m], [p4[0], p4[1], p4[2], p4[3]]);
      expect(
        [p1.optZ, p1.optM, p2.optM, p3.optZ],
        [null, null, null, null],
      );

      expect(Position.view([1.0, 2.0]), p1);
      expect(Position.view([1.0, 2.0, 3.0]), p2);
      expect(Position.view([1.0, 2.0, 4.0]) == p3, false);
      expect(Position.view([1.0, 2.0, 4.0], type: Coords.xym), p3);
      expect(Position.view([1.0, 2.0, 3.0, 4.0]), p4);

      expect(Position.parse('1.0,2.0'), p1);
      expect(Position.parse('1.0,2.0,3.0'), p2);
      expect(Position.parse('1.0,2.0,4.0', type: Coords.xym), p3);
      expect(Position.parse('1.0,2.0,3.0,4.0'), p4);
      expect(Position.parse('1.0 2.0 3.0 4.0', delimiter: ' '), p4);

      expect(
        () => Position.view([1.0], type: Coords.xy).y,
        throwsFormatException,
      );
      expect(() => Position.view([1.0]).y, throwsFormatException);
      expect(() => Position.parse('1.0'), throwsFormatException);
      expect(
        () => Position.parse('1.0,2.0,x'),
        throwsFormatException,
      );
    });

    test('Equals and hashCode', () {
      // test Position itself
      final one = 1.0;
      final two = 2.0;
      final p1 = [1.0, 2.0, 3.0, 4.0].xyzm;
      final p2 = [one, 2.0, 3.0, 4.0].xyzm;
      final p3 = [two, 2.0, 3.0, 4.0].xyzm;
      expect(p1, p2);
      expect(p1, isNot(p3));
      expect(p1.hashCode, p2.hashCode);
      expect(p1.hashCode, isNot(p3.hashCode));
      expect(p1.equals2D(p2), true);
      expect(p1.equals2D(p3), false);
      expect(p1.equals3D(p2), true);
      expect(p1.equals3D(p3), false);

      // copy to
      expect(p1, p1.copyTo(Position.create));
      expect(p1, p1.copyTo(Geographic.create));

      // with some coordinates missing or other type
      const p5 = Projected(x: 1.0, y: 2.0, z: 3.0);
      const p6 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0);
      const p7 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0, m: 4.0);
      expect(p1, isNot(p5));
      expect(p1, isNot(p6));
      expect(p1, p7);
      expect(p5, p6);
      expect(p6, isNot(p7));

      final p8 = [1.0, 2.0].xy;
      expect(p1.equals2D(p8), true);
      expect(p1.equals3D(p8), false);
    });

    test('Equals with tolerance', () {
      final p1 = Position.create(x: 1.0002, y: 2.0002, z: 3.002, m: 4.0);
      final p2 = Position.create(x: 1.0003, y: 2.0003, z: 3.003, m: 4.0);
      expect(p1.equals2D(p2), false);
      expect(p1.equals3D(p2), false);
      expect(p1.equals2D(p2, toleranceHoriz: 0.00011), true);
      expect(p1.equals3D(p2, toleranceHoriz: 0.00011), false);
      expect(p1.equals2D(p2, toleranceHoriz: 0.00011), true);
      expect(
        p1.equals3D(p2, toleranceHoriz: 0.00011, toleranceVert: 0.0011),
        true,
      );
      expect(p1.equals2D(p2, toleranceHoriz: 0.00009), false);
      expect(
        p1.equals3D(p2, toleranceHoriz: 0.00011, toleranceVert: 0.0009),
        false,
      );
    });

    test('Distances 2D', () {
      expect([1.0, 1.0].xy.distanceTo2D([1.0, 1.0].xy), 0.0);
      expect([1.0, 1.0].xy.distanceTo2D([4.0, 1.0].xy), 3.0);
      expect([1.0, 1.0].xy.distanceTo2D([1.0, 4.0].xy), 3.0);
      expect(
        [1.0, 1.0].xy.distanceTo2D([4.0, 4.0].xy),
        closeTo(4.242640687119285, 0.0000000000001),
      );
    });

    test('Distances 3D', () {
      expect([1.0, 1.0, 1.0].xyz.distanceTo2D([1.0, 1.0, 1.0].xyz), 0.0);
      expect([1.0, 1.0, 1.0].xyz.distanceTo3D([4.0, 1.0, 1.0].xyz), 3.0);
      expect([1.0, 1.0, 1.0].xyz.distanceTo3D([1.0, 4.0, 1.0].xyz), 3.0);
      expect([1.0, 1.0, 1.0].xyz.distanceTo3D([1.0, 1.0, 4.0].xyz), 3.0);
      expect(
        [1.0, 1.0, 1.0].xyz.distanceTo3D([4.0, 4.0, 4.0].xyz),
        closeTo(5.196152422706632, 0.0000000000001),
      );
    });

    test('Bearings 2D', () {
      expect([1.0, 1.0].xy.bearingTo2D([1.0, 1.0].xy), 0.0);

      expect([1.0, 1.0].xy.bearingTo2D([4.0, 1.0].xy), 90.0);
      expect([1.0, 1.0].xy.bearingTo2D([1.0, 4.0].xy), 0.0);
      expect([1.0, 1.0].xy.bearingTo2D([-4.0, 1.0].xy), 270.0);
      expect([1.0, 1.0].xy.bearingTo2D([1.0, -4.0].xy), 180.0);

      expect([1.0, 1.0].xy.bearingTo2D([1.5, 1.5].xy), 45.0);
      expect([1.0, 1.0].xy.bearingTo2D([1.5, 0.5].xy), 135.0);
      expect([1.0, 1.0].xy.bearingTo2D([0.5, 0.5].xy), 225.0);
      expect([1.0, 1.0].xy.bearingTo2D([0.5, 1.5].xy), 315.0);
    });

    test('Midpoints', () {
      expect([1.0, 1.0].xy.midPointTo([4.0, 4.0].xy), [2.5, 2.5].xy);
      expect(
        [1.0, 1.0, -1.0].xyz.midPointTo([4.0, 4.0, -4.0].xyz),
        [2.5, 2.5, -2.5].xyz,
      );
      expect(
        [1.0, 1.0, -1.0].xym.midPointTo([4.0, 4.0, -4.0].xym),
        [2.5, 2.5, -2.5].xym,
      );
      expect(
        [1.0, 1.0, -1.0].xyz.midPointTo([4.0, 4.0, -4.0].xym),
        [2.5, 2.5].xy,
      );
      expect(
        [0.0, -4.0, -1.0, 1.0].xyzm.midPointTo([0.0, -8.0, -4.0, -4.0].xyzm),
        [0.0, -6.0, -2.5, -1.5].xyzm,
      );
    });

    test('Intermediate points', () {
      final p1 = Position.create(x: 0.119, y: 52.205);
      final p2 = Position.create(x: 2.351, y: 48.857);

      // intermediate point (x: 0.677, y: 51.368)
      final pInt = p1.intermediatePointTo(p2, fraction: 0.25);
      expect(pInt.toText(decimals: 3), '0.677,51.368');

      expect(
        [0.0, 0.0].xy.intermediatePointTo([4.0, 4.0].xy, fraction: -1.0),
        [-4.0, -4.0].xy,
      );
      expect(
        [0.0, 0.0].xy.intermediatePointTo([4.0, 4.0].xy, fraction: 0.0),
        [0.0, 0.0].xy,
      );
      expect(
        [0.0, 0.0].xy.intermediatePointTo([4.0, 4.0].xy, fraction: 0.5),
        [2.0, 2.0].xy,
      );
      expect(
        [0.0, 0.0].xy.intermediatePointTo([4.0, 4.0].xy, fraction: 1.0),
        [4.0, 4.0].xy,
      );
      expect(
        [0.0, 0.0].xy.intermediatePointTo([4.0, 4.0].xy, fraction: 2.0),
        [8.0, 8.0].xy,
      );

      expect(
        [-0.0, -0.0].xy.intermediatePointTo([-4.0, -4.0].xy, fraction: 0.25),
        [-1.0, -1.0].xy,
      );
      expect(
        [-0.0, -0.0, -0.1]
            .xyz
            .intermediatePointTo([-4.0, -4.0, -0.5].xyz, fraction: 0.25),
        [-1.0, -1.0, -0.2].xyz,
      );
      expect(
        [-0.0, -0.0, -0.1]
            .xym
            .intermediatePointTo([-4.0, -4.0, -0.5].xym, fraction: 0.25),
        [-1.0, -1.0, -0.2].xym,
      );
      expect(
        [-0.0, -0.0, -0.1, 0.1]
            .xyzm
            .intermediatePointTo([-4.0, -4.0, -0.5, 0.5].xyzm, fraction: 0.25),
        [-1.0, -1.0, -0.2, 0.2].xyzm,
      );
    });

    test('Destination points', () {
      final p1 = Position.create(x: 0.119, y: 52.205);

      // destination point (x: 2.351, y: 48.857)
      final pInt = p1.destinationPoint2D(bearing: 146.31, distance: 4.024);
      expect(pInt.toText(decimals: 3), '2.351,48.857');

      expect(
        [2.1, 2.1]
            .xy
            .destinationPoint2D(distance: 2.0, bearing: 0.0)
            .toText(decimals: 3),
        [2.1, 4.1].xy.toText(decimals: 3),
      );
      expect(
        [2.1, 2.1]
            .xy
            .destinationPoint2D(distance: 2.0, bearing: 90.0)
            .toText(decimals: 3),
        [4.1, 2.1].xy.toText(decimals: 3),
      );
      expect(
        [2.1, 2.1]
            .xy
            .destinationPoint2D(distance: 2.0, bearing: 180.0)
            .toText(decimals: 3),
        [2.1, 0.1].xy.toText(decimals: 3),
      );
      expect(
        [2.1, 2.1]
            .xy
            .destinationPoint2D(distance: 2.0, bearing: 270.0)
            .toText(decimals: 3),
        [0.1, 2.1].xy.toText(decimals: 3),
      );

      final tests = [
        [34.5, -223.3].xy,
        [-12.23, -598.23].xy,
        [-592.3, -16.42].xy,
        [-34.4, -58.7].xy,
        [-53.23, 48.34].xy,
        [64.344, 27.45].xy,
        [73.42, -59.99].xy,
        [0.001, 0.001].xy,
        [-0.001, -0.001].xy,
      ];

      Position? prev;
      for (final test in tests) {
        if (prev != null) {
          final bearing1 = test.bearingTo2D(prev);
          final distance1 = test.distanceTo2D(prev);
          final bearing2 = prev.bearingTo2D(test);
          final distance2 = prev.distanceTo2D(test);

          expect(bearing1, closeTo((bearing2 + 180.0) % 360.0, 0.000000000001));
          expect(distance1, distance2);

          expect(
            test.toText(decimals: 3),
            prev
                .destinationPoint2D(distance: distance2, bearing: bearing2)
                .toText(decimals: 3),
          );
          expect(
            prev.toText(decimals: 3),
            test
                .destinationPoint2D(distance: distance1, bearing: bearing1)
                .toText(decimals: 3),
          );
          expect(
            test,
            test.destinationPoint2D(distance: 0.0, bearing: bearing1),
          );
        }
        prev = test;
      }
    });

    test('Sum', () {
      expect([1.0, 1.0].xy + [4.0, 4.0].xy, [5.0, 5.0].xy);
      expect([1.0, 1.0, -3.0].xyz + [4.0, 4.0, 2.0].xyz, [5.0, 5.0, -1.0].xyz);
      expect([1.0, 1.0, -3.0].xym + [4.0, 4.0, 2.0].xym, [5.0, 5.0, -1.0].xym);
      expect([1.0, 1.0, -3.0].xyz + [4.0, 4.0, 2.0].xym, [5.0, 5.0].xy);
      expect(
        [1.0, 1.0, -3.0, 0.0].xyzm + [4.0, 4.0, 2.0, 1.0].xyzm,
        [5.0, 5.0, -1.0, 1.0].xyzm,
      );
    });

    test('Subtract', () {
      expect([1.0, 1.0].xy - [4.0, 4.0].xy, [-3.0, -3.0].xy);
      expect(
        [1.0, 1.0, -3.0].xyz - [4.0, 4.0, 2.0].xyz,
        [-3.0, -3.0, -5.0].xyz,
      );
      expect(
        [1.0, 1.0, -3.0].xym - [4.0, 4.0, 2.0].xym,
        [-3.0, -3.0, -5.0].xym,
      );
      expect([1.0, 1.0, -3.0].xyz - [4.0, 4.0, 2.0].xym, [-3.0, -3.0].xy);
      expect(
        [1.0, 1.0, -3.0, 0.0].xyzm - [4.0, 4.0, 2.0, 1.0].xyzm,
        [-3.0, -3.0, -5.0, -1.0].xyzm,
      );
    });

    test('Copy with', () {
      expect(
        [1.0, 1.0].xy.copyWith(),
        [1.0, 1.0].xy,
      );
      expect(
        [1.0, 1.0].xy.copyWith(y: 2.0),
        [1.0, 2.0].xy,
      );
      expect(
        [1.0, 1.0].xy.copyWith(z: 2.0),
        [1.0, 1.0, 2.0].xyz,
      );
    });

    test('Subview', () {
      final coordinates = [1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3];
      final pos1 = Position.subview(coordinates, start: 3, type: Coords.xyz);
      final packed1 = pos1.packed();
      final series = PositionSeries.view(coordinates, type: Coords.xyz);
      final pos2 = series[1];
      final pos3 = series.reversed()[1];
      final packed3 = pos3.packed();

      for (final pos in [pos1, packed1, pos2, pos3, packed3]) {
        expect(pos.toString(), '2.1,2.2,2.3');
        expect(pos.values, [2.1, 2.2, 2.3]);
        expect(pos.valuesByType(Coords.xy), [2.1, 2.2]);
        expect(pos.valuesByType(Coords.xyz), [2.1, 2.2, 2.3]);
        expect(pos.valuesByType(Coords.xym), [2.1, 2.2, 0.0]);
        expect(pos.valuesByType(Coords.xyzm), [2.1, 2.2, 2.3, 0.0]);
        expect(pos.z, 2.3);
        expect(pos.optZ, 2.3);
        expect(pos.m, 0.0);
        expect(pos.optM, isNull);
      }

      expect(
        () => Position.subview(coordinates, start: 7, type: Coords.xyz),
        throwsFormatException,
      );
    });
  });

  group('Other tests', () {
    test('Coordinate order', () {
      // XY
      _testCoordinateOrder('1.0,2.0', [1.0, 2.0]);
      _testCoordinateOrder('1.0,2.0', [1.0, 2.0], Coords.xy);

      // XYZ
      _testCoordinateOrder('1.0,2.0,3.0', [1.0, 2.0, 3.0]);
      _testCoordinateOrder('1.0,2.0,3.0', [1.0, 2.0, 3.0], Coords.xyz);

      // XYM
      _testCoordinateOrder('1.0,2.0,4.0', [1.0, 2.0, 4.0], Coords.xym);

      // XYZM
      _testCoordinateOrder('1.0,2.0,3.0,4.0', [1.0, 2.0, 3.0, 4.0]);
      _testCoordinateOrder(
        '1.0,2.0,3.0,4.0',
        [1.0, 2.0, 3.0, 4.0],
        Coords.xyzm,
      );
    });
  });
}

void _testCoordinateOrder(
  String text,
  List<double> coords, [
  Coords? type,
]) {
  final factories = [Position.create];

  for (final factory in factories) {
    final fromCoords = Position.buildPosition(coords, to: factory, type: type);
    final fromText = Position.parsePosition(text, to: factory, type: type);
    expect(fromCoords, fromText);
    expect(fromCoords.toString(), text);
    expect(fromText.values, coords);
    for (var i = 0; i < coords.length; i++) {
      expect(fromText[i], coords.elementAt(i));
    }

    expect(
      Position.createFromObject(coords, to: factory, type: type),
      fromCoords,
    );

    expect(
      Position.view(
        coords,
        type: type ?? Coords.fromDimension(coords.length),
      ),
      fromCoords,
    );
  }
}
