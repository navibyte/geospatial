// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: unrelated_type_equality_checks, prefer_const_declarations

import 'package:geobase/coordinates.dart';
import 'package:geobase/vector_data.dart';

import 'package:test/test.dart';

void main() {
  group('Projected coords as iterable', () {
    test('Coordinate values as iterable', () {
      // xyz and xym coordinates
      const xyzData = [15, 30, 45];
      const xymData = [15, 30, 60];

      // positions from data
      final xyzPos = XYZ.view(xyzData);
      final xymPos = XYM.view(xymData);

      // positions as lists equals to their representive iterable representation
      expect(xyzPos.toList(), xyzData);
      expect(xymPos.toList(), xymData);

      // positions equals to their representive iterable representation
      expect(xyzPos, xyzData);
      expect(xymPos, xymData);

      // but not vice versa, as expected
      expect(xyzPos, isNot(xymData));
      expect(xymPos, isNot(xyzData));

      // then we create "XYZ" position from "XYM" data
      final xyzPosFromXym = XYZ.view(xymData);

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
      expect(xymData, xyzPosFromXym);

      // testing by values (xymPos vs xyzPos)
      expect(xymPos[0], xyzPos[0]);
      expect(xymPos[1], xyzPos[1]);
      expect(xymPos[2], isNot(xyzPos[2]));
      expect(xymPos.elementAt(0), xyzPos.elementAt(0));
      expect(xymPos.elementAt(1), xyzPos.elementAt(1));
      expect(xymPos.elementAt(2), isNot(xyzPos.elementAt(2)));
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
      expect(xymPos.elementAt(0), xyzPosFromXym.elementAt(0));
      expect(xymPos.elementAt(1), xyzPosFromXym.elementAt(1));
      expect(xymPos.elementAt(2), xyzPosFromXym.elementAt(2));
      expect(xymPos.x, xyzPosFromXym.x);
      expect(xymPos.y, xyzPosFromXym.y);
      expect(xymPos.z, isNot(xyzPosFromXym.z));
      expect(xymPos.m, isNot(xyzPosFromXym.m));
      expect(xymPos.optM, isNotNull);
      expect(xymPos.optZ, isNull);
      expect(xyzPosFromXym.optM, isNull);
      expect(xyzPosFromXym.optZ, isNotNull);
    });

    test('Coordinate access and factories', () {
      final p1 = XY.create(x: 1.0, y: 2.0);
      final p2 = XYZ.create(x: 1.0, y: 2.0, z: 3.0);
      final p3 = XYM.create(x: 1.0, y: 2.0, m: 4.0);
      final p4 = XYZM.create(x: 1.0, y: 2.0, z: 3.0, m: 4.0);
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

      expect(ProjectedCoords.view(const [1.0, 2.0]), p1);
      expect(ProjectedCoords.view(const [1.0, 2.0, 3.0]), p2);
      expect(ProjectedCoords.view(const [1.0, 2.0, 4.0]) == p3, false);
      expect(ProjectedCoords.view(const [1.0, 2.0, 4.0], type: Coords.xym), p3);
      expect(ProjectedCoords.view(const [1.0, 2.0, 3.0, 4.0]), p4);

      expect(ProjectedCoords.fromText('1.0,2.0'), p1);
      expect(ProjectedCoords.fromText('1.0,2.0,3.0'), p2);
      expect(ProjectedCoords.fromText('1.0,2.0,4.0', type: Coords.xym), p3);
      expect(ProjectedCoords.fromText('1.0,2.0,3.0,4.0'), p4);

      expect(XY.fromText(p1.toString()), p1);
      expect(XYZ.fromText(p2.toString()), p2);
      expect(XYM.fromText(p3.toString()), p3);
      expect(XYZM.fromText(p4.toString()), p4);
      expect(XYZM.fromText('1.0 2.0 3.0 4.0', delimiter: ' '), p4);

      expect(() => ProjectedCoords.view(const [1.0]), throwsFormatException);
      expect(() => ProjectedCoords.fromText('1.0'), throwsFormatException);
      expect(
        () => ProjectedCoords.fromText('1.0,2.0,x'),
        throwsFormatException,
      );
    });

    test('Equals and hashCode', () {
      // test Position itself
      final one = 1.0;
      final two = 2.0;
      final p1 = XYZM(1.0, 2.0, 3.0, 4.0);
      final p2 = XYZM(one, 2.0, 3.0, 4.0);
      final p3 = XYZM(two, 2.0, 3.0, 4.0);
      expect(p1, p2);
      expect(p1, isNot(p3));
      expect(p1.hashCode, p2.hashCode);
      expect(p1.hashCode, isNot(p3.hashCode));
      expect(p1.equals2D(p2), true);
      expect(p1.equals2D(p3), false);
      expect(p1.equals3D(p2), true);
      expect(p1.equals3D(p3), false);

      // copy to
      expect(p1, p1.copyTo(ProjectedCoords.create));
      expect(p1 == p1.copyTo(GeographicCoords.create), false);

      // with some coordinates missing or other type
      const p5 = Projected(x: 1.0, y: 2.0, z: 3.0);
      const p6 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0);
      const p7 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0, m: 4.0);
      expect(p1, isNot(p5));
      expect(p1, isNot(p6));
      expect(p1, isNot(p7));
      expect(p5, isNot(p6));
      expect(p6, isNot(p7));

      final p8 = XY.create(x: 1.0, y: 2.0);
      expect(p1.equals2D(p8), true);
      expect(p1.equals3D(p8), false);
    });

    test('Equals with tolerance', () {
      final p1 = ProjectedCoords.create(x: 1.0002, y: 2.0002, z: 3.002, m: 4.0);
      final p2 = ProjectedCoords.create(x: 1.0003, y: 2.0003, z: 3.003, m: 4.0);
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
        XY.create(x: 1, y: 1).copyWith(),
        XY.create(x: 1, y: 1),
      );
      expect(
        XY.create(x: 1, y: 1).copyWith(y: 2),
        XY.create(x: 1, y: 2),
      );
      expect(
        XY.create(x: 1, y: 1).copyWith(z: 2),
        XY.create(x: 1, y: 1),
      );
    });
  });

  group('Geographic coordinates as iterable', () {
    test('Coordinate access and factories', () {
      final p1 = LonLat.create(x: 1.0, y: 2.0);
      final p2 = LonLatElev.create(x: 1.0, y: 2.0, z: 3.0);
      final p3 = LonLatM.create(x: 1.0, y: 2.0, m: 4.0);
      final p4 = LonLatElevM.create(x: 1.0, y: 2.0, z: 3.0, m: 4.0);
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

      expect(GeographicCoords.view(const [1.0, 2.0]), p1);
      expect(GeographicCoords.view(const [1.0, 2.0, 3.0]), p2);
      expect(GeographicCoords.view(const [1.0, 2.0, 4.0]) == p3, false);
      expect(
        GeographicCoords.view(const [1.0, 2.0, 4.0], type: Coords.xym),
        p3,
      );
      expect(GeographicCoords.view(const [1.0, 2.0, 3.0, 4.0]), p4);

      expect(GeographicCoords.fromText('1.0,2.0'), p1);
      expect(GeographicCoords.fromText('1.0,2.0,3.0'), p2);
      expect(GeographicCoords.fromText('1.0,2.0,4.0', type: Coords.xym), p3);
      expect(GeographicCoords.fromText('1.0,2.0,3.0,4.0'), p4);

      expect(LonLat.fromText(p1.toString()), p1);
      expect(LonLatElev.fromText(p2.toString()), p2);
      expect(LonLatM.fromText(p3.toString()), p3);
      expect(LonLatElevM.fromText(p4.toString()), p4);
      expect(LonLatElevM.fromText('1.0 2.0 3.0 4.0', delimiter: ' '), p4);

      expect(() => GeographicCoords.view(const [1.0]), throwsFormatException);
      expect(() => GeographicCoords.fromText('1.0'), throwsFormatException);
      expect(
        () => GeographicCoords.fromText('1.0,2.0,x'),
        throwsFormatException,
      );
    });

    test('Equals and hashCode', () {
      // test Position itself
      final one = 1.0;
      final two = 2.0;
      final p1 = LonLatElevM(1.0, 2.0, 3.0, 4.0);
      final p2 = LonLatElevM(one, 2.0, 3.0, 4.0);
      final p3 = LonLatElevM(two, 2.0, 3.0, 4.0);
      expect(p1, p2);
      expect(p1, isNot(p3));
      expect(p1.hashCode, p2.hashCode);
      expect(p1.hashCode, isNot(p3.hashCode));
      expect(p1.equals2D(p2), true);
      expect(p1.equals2D(p3), false);
      expect(p1.equals3D(p2), true);
      expect(p1.equals3D(p3), false);

      // copy to
      expect(p1, p1.copyTo(GeographicCoords.create));
      expect(p1 == p1.copyTo(ProjectedCoords.create), false);

      // with some coordinates missing or other type
      const p5 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0);
      const p6 = Projected(x: 1.0, y: 2.0, z: 3.0);
      const p7 = Projected(x: 1.0, y: 2.0, z: 3.0, m: 4.0);
      expect(p1, isNot(p5));
      expect(p1, isNot(p6));
      expect(p1, isNot(p7));
      expect(p5, isNot(p6));
      expect(p6, isNot(p7));

      final p8 = LonLat.create(x: 1.0, y: 2.0);
      expect(p1.equals2D(p8), true);
      expect(p1.equals3D(p8), false);
    });

    test('Equals with tolerance', () {
      final p1 = ProjectedCoords.create(x: 1.0002, y: 2.0002, z: 3.002, m: 4.0);
      final p2 = ProjectedCoords.create(x: 1.0003, y: 2.0003, z: 3.003, m: 4.0);
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
        XY.create(x: 1, y: 1).copyWith(),
        XY.create(x: 1, y: 1),
      );
      expect(
        XY.create(x: 1, y: 1).copyWith(y: 2),
        XY.create(x: 1, y: 2),
      );
      expect(
        XY.create(x: 1, y: 1).copyWith(z: 2),
        XY.create(x: 1, y: 1),
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

void _testCoordinateOrder(String text, Iterable<num> coords, [Coords? type]) {
  final factories = [ProjectedCoords.create, GeographicCoords.create];

  for (final factory in factories) {
    final fromCoords =
        Position.createFromCoords(coords, to: factory, type: type);
    final fromText = Position.createFromText(text, to: factory, type: type);
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
      ProjectedCoords.view(coords, type: type),
      fromCoords,
    );

    expect(
      GeographicCoords.fromCoords(coords, type: type),
      fromCoords,
    );
  }
}
