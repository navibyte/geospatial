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
