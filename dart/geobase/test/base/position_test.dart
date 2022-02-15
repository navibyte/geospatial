// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_declarations

import 'package:geobase/geobase.dart';
import 'package:meta/meta.dart';

import 'package:test/test.dart';

void main() {
  group('Position class', () {
    test('Coordinate access', () {
      const p1 = Position(x: 1.0, y: 2.0);
      const p2 = Position(x: 1.0, y: 2.0, z: 3.0);
      const p3 = Position(x: 1.0, y: 2.0, m: 4.0);
      const p4 = Position(x: 1.0, y: 2.0, z: 3.0, m: 4.0);
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
    });

    test('Equals and hashCode', () {
      // test Position itself
      final one = 1.0;
      final two = 2.0;
      const p1 = Position(x: 1.0, y: 2.0, z: 3.0, m: 4.0);
      final p2 = Position(x: one, y: 2.0, z: 3.0, m: 4.0);
      final p3 = Position(x: two, y: 2.0, z: 3.0, m: 4.0);
      expect(p1, p2);
      expect(p1, isNot(p3));
      expect(p1.hashCode, p2.hashCode);
      expect(p1.hashCode, isNot(p3.hashCode));
      expect(p1.equals2D(p2), true);
      expect(p1.equals2D(p3), false);
      expect(p1.equals3D(p2), true);
      expect(p1.equals3D(p3), false);

      // test private class that implements Position interface
      const t1 = _TestXYZM(x: 1.0, y: 2.0, z: 3.0, m: 4.0);
      final t2 = _TestXYZM(x: one, y: 2.0, z: 3.0, m: 4.0);
      final t3 = _TestXYZM(x: two, y: 2.0, z: 3.0, m: 4.0);
      expect(t1, t2);
      expect(t1, isNot(t3));
      expect(t1.hashCode, t2.hashCode);
      expect(t1.hashCode, isNot(t3.hashCode));

      // test between Position and class implementing it's interface
      expect(p1, t2);
      expect(t1, p2);
      expect(p1, isNot(t3));
      expect(t1, isNot(p3));
      expect(p1.hashCode, t2.hashCode);
      expect(p1.hashCode, isNot(t3.hashCode));

      // with some coordinates missing or other type
      const p5 = Position(x: 1.0, y: 2.0, z: 3.0);
      const p6 = GeoPosition(lon: 1.0, lat: 2.0, elev: 3.0);
      const p7 = GeoPosition(lon: 1.0, lat: 2.0, elev: 3.0, m: 4.0);
      expect(p1, isNot(p5));
      expect(p1, isNot(p6));
      expect(p1, isNot(p7));
      expect(p5, isNot(p6));
      expect(p6, isNot(p7));

      final p8 = const Position(x: 1.0, y: 2.0);
      expect(p1.equals2D(p8), true);
      expect(p1.equals3D(p8), false);
    });

    test('Equals with tolerance', () {
      const p1 = Position(x: 1.0002, y: 2.0002, z: 3.002, m: 4.0);
      const p2 = Position(x: 1.0003, y: 2.0003, z: 3.003, m: 4.0);
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
        const Position(x: 1, y: 1).copyWith(),
        const Position(x: 1, y: 1),
      );
      expect(
        const Position(x: 1, y: 1).copyWith(y: 2),
        const Position(x: 1, y: 2),
      );
      expect(
        const Position(x: 1, y: 1).copyWith(z: 2),
        const Position(x: 1, y: 1, z: 2),
      );
    });
  });

  group('GeoPosition class', () {
    test('Coordinate access', () {
      const p1 = GeoPosition(lon: 1.0, lat: 2.0);
      const p2 = GeoPosition(lon: 1.0, lat: 2.0, elev: 3.0);
      const p3 = GeoPosition(lon: 1.0, lat: 2.0, m: 4.0);
      const p4 = GeoPosition(lon: 1.0, lat: 2.0, elev: 3.0, m: 4.0);
      expect([p1.lon, p1.lat], p1.values);
      expect([p2.lon, p2.lat, p2.elev], p2.values);
      expect([p3.lon, p3.lat, p3.m], p3.values);
      expect([p4.lon, p4.lat, p4.elev, p4.m], p4.values);
      expect([p1.lon, p1.lat, 0, 0], [p1[0], p1[1], p1[2], p1[3]]);
      expect([p2.lon, p2.lat, p2.elev, 0], [p2[0], p2[1], p2[2], p2[3]]);
      expect([p3.lon, p3.lat, p3.m, 0], [p3[0], p3[1], p3[2], p3[3]]);
      expect([p4.lon, p4.lat, p4.elev, p4.m], [p4[0], p4[1], p4[2], p4[3]]);
      expect(
        [p1.optElev, p1.optM, p2.optM, p3.optElev],
        [null, null, null, null],
      );
    });

    test('Equals and hashCode', () {
      final one = 1.0;
      final two = 2.0;
      const p1 = GeoPosition(lon: 1.0, lat: 2.0, elev: 3.0, m: 4.0);
      final p2 = GeoPosition(lon: one, lat: 2.0, elev: 3.0, m: 4.0);
      final p3 = GeoPosition(lon: two, lat: 2.0, elev: 3.0, m: 4.0);
      expect(p1, p2);
      expect(p1, isNot(p3));
      expect(p1.hashCode, p2.hashCode);
      expect(p1.hashCode, isNot(p3.hashCode));
      expect(p1.equals2D(p2), true);
      expect(p1.equals2D(p3), false);
      expect(p1.equals3D(p2), true);
      expect(p1.equals3D(p3), false);
    });

    test('Equals with tolerance', () {
      const p1 = GeoPosition(lon: 1.0002, lat: 2.0002, elev: 3.002, m: 4.0);
      const p2 = GeoPosition(lon: 1.0003, lat: 2.0003, elev: 3.003, m: 4.0);
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

    test('Clamping longitude and latitude in constructor', () {
      expect(const GeoPosition(lon: 34.0, lat: 18.2).lon, 34.0);
      expect(const GeoPosition(lon: -326.0, lat: 18.2).lon, 34.0);
      expect(const GeoPosition(lon: 394.0, lat: 18.2).lon, 34.0);
      expect(const GeoPosition(lon: -180.0, lat: 18.2).lon, -180.0);
      expect(const GeoPosition(lon: -181.0, lat: 18.2).lon, 179.0);
      expect(const GeoPosition(lon: -541.0, lat: 18.2).lon, 179.0);
      expect(const GeoPosition(lon: 180.0, lat: 18.2).lon, -180.0);
      expect(const GeoPosition(lon: 181.0, lat: 18.2).lon, -179.0);
      expect(const GeoPosition(lon: 541.0, lat: 18.2).lon, -179.0);
      expect(const GeoPosition(lon: 34.2, lat: -90.0).lat, -90.0);
      expect(const GeoPosition(lon: 34.2, lat: -91.0).lat, -90.0);
      expect(const GeoPosition(lon: 34.2, lat: 90.0).lat, 90.0);
      expect(const GeoPosition(lon: 34.2, lat: 91.0).lat, 90.0);
    });

    test('Copy with', () {
      expect(
        const GeoPosition(lon: 1.0, lat: 1.0).copyWith(),
        const GeoPosition(lon: 1.0, lat: 1.0),
      );
      expect(
        const GeoPosition(lon: 1.0, lat: 1.0).copyWith(y: 2.0),
        const GeoPosition(lon: 1.0, lat: 2.0),
      );
      expect(
        const GeoPosition(lon: 1.0, lat: 1.0).copyWith(z: 2.0),
        const GeoPosition(lon: 1.0, lat: 1.0, elev: 2.0),
      );
    });
  });
}

@immutable
class _TestXYZM implements Position {
  const _TestXYZM({
    required this.x,
    required this.y,
    required this.z,
    required this.m,
  });

  @override
  Position copyWith({num? x, num? y, num? z, num? m}) => Position(
        x: x ?? this.x,
        y: y ?? this.y,
        z: z ?? this.z,
        m: m ?? this.m,
      );

  @override
  Position transform(TransformPosition transform) => transform(this);

  @override
  num operator [](int i) => Position.getValue(this, i);

  @override
  Iterable<num> get values => Position.getValues(this);

  @override
  final num x;
  @override
  final num y;
  @override
  final num z;
  @override
  final num m;

  @override
  num? get optZ => z;

  @override
  num? get optM => m;

  @override
  Position get asPosition => this;

  @override
  int get spatialDimension => typeCoords.spatialDimension;

  @override
  int get coordinateDimension => typeCoords.coordinateDimension;

  @override
  bool get isGeographic => false;

  @override
  bool get is3D => true;

  @override
  bool get isMeasured => true;

  @override
  Coords get typeCoords => CoordsExtension.select(
        isGeographic: isGeographic,
        is3D: is3D,
        isMeasured: isMeasured,
      );

  @override
  String toString() => '$x,$y,$z,$m';

  @override
  bool equals2D(BasePosition other, {num? toleranceHoriz}) =>
      other is Position &&
      Position.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

  @override
  bool equals3D(
    BasePosition other, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) =>
      other is Position &&
      Position.testEquals3D(
        this,
        other,
        toleranceHoriz: toleranceHoriz,
        toleranceVert: toleranceVert,
      );

  @override
  bool operator ==(Object other) =>
      other is Position && Position.testEquals(this, other);

  @override
  int get hashCode => Position.hash(this);
}
