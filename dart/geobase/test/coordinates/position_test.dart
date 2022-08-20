// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: prefer_const_declarations

import 'package:geobase/coordinates.dart';

import 'package:meta/meta.dart';

import 'package:test/test.dart';

void main() {
  group('Projected class', () {
    test('Coordinate access and factories', () {
      const p1 = Projected(x: 1.0, y: 2.0);
      const p2 = Projected(x: 1.0, y: 2.0, z: 3.0);
      const p3 = Projected(x: 1.0, y: 2.0, m: 4.0);
      const p4 = Projected(x: 1.0, y: 2.0, z: 3.0, m: 4.0);
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

      expect(Projected.build(const [1.0, 2.0]), p1);
      expect(Projected.build(const [1.0, 2.0, 3.0]), p2);
      expect(Projected.build(const [1.0, 2.0, 4.0]), isNot(p3));
      expect(Projected.build(const [1.0, 2.0, 4.0], type: Coords.xym), p3);
      expect(Projected.build(const [1.0, 2.0, 3.0, 4.0]), p4);

      expect(Projected.parse('1.0,2.0'), p1);
      expect(Projected.parse('1.0,2.0,3.0'), p2);
      expect(Projected.parse('1.0,2.0,4.0', type: Coords.xym), p3);
      expect(Projected.parse('1.0,2.0,3.0,4.0'), p4);

      expect(Projected.parse(p1.toString()), p1);
      expect(Projected.parse(p2.toString()), p2);
      expect(Projected.parse(p3.toString(), type: Coords.xym), p3);
      expect(Projected.parse(p4.toString()), p4);
      expect(Projected.parse('1.0 2.0 3.0 4.0', delimiter: ' '), p4);

      expect(() => Projected.build(const [1.0]), throwsFormatException);
      expect(() => Projected.parse('1.0'), throwsFormatException);
      expect(() => Projected.parse('1.0,2.0,x'), throwsFormatException);
    });

    test('Equals and hashCode', () {
      // test Position itself
      final one = 1.0;
      final two = 2.0;
      const p1 = Projected(x: 1.0, y: 2.0, z: 3.0, m: 4.0);
      final p2 = Projected(x: one, y: 2.0, z: 3.0, m: 4.0);
      final p3 = Projected(x: two, y: 2.0, z: 3.0, m: 4.0);
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

      // copy to
      expect(p1, p1.copyTo(Projected.create));
      expect(p1, p1.copyTo(Geographic.create));
      expect(p1, p1.copyTo(_TestXYZM.create));
      expect(t1, t1.copyTo(Projected.create));
      expect(t1, t1.copyTo(_TestXYZM.create));

      // test between Position and class implementing it's interface
      expect(p1, t2);
      expect(t1, p2);
      expect(p1, isNot(t3));
      expect(t1, isNot(p3));
      expect(p1.hashCode, t2.hashCode);
      expect(p1.hashCode, isNot(t3.hashCode));

      // with some coordinates missing or other type
      const p5 = Projected(x: 1.0, y: 2.0, z: 3.0);
      const p6 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0);
      const p7 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0, m: 4.0);
      expect(p1, isNot(p5));
      expect(p1, isNot(p6));
      expect(p1, p7);
      expect(p5, p6);
      expect(p6, isNot(p7));

      final p8 = const Projected(x: 1.0, y: 2.0);
      expect(p1.equals2D(p8), true);
      expect(p1.equals3D(p8), false);
    });

    test('Equals with tolerance', () {
      const p1 = Projected(x: 1.0002, y: 2.0002, z: 3.002, m: 4.0);
      const p2 = Projected(x: 1.0003, y: 2.0003, z: 3.003, m: 4.0);
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
        const Projected(x: 1, y: 1).copyWith(),
        const Projected(x: 1, y: 1),
      );
      expect(
        const Projected(x: 1, y: 1).copyWith(y: 2),
        const Projected(x: 1, y: 2),
      );
      expect(
        const Projected(x: 1, y: 1).copyWith(z: 2),
        const Projected(x: 1, y: 1, z: 2),
      );
    });
  });

  group('Geographic class', () {
    test('Coordinate access and factories', () {
      const p1 = Geographic(lon: 1.0, lat: 2.0);
      const p2 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0);
      const p3 = Geographic(lon: 1.0, lat: 2.0, m: 4.0);
      const p4 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0, m: 4.0);
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

      expect(Geographic.build(const [1.0, 2.0]), p1);
      expect(Geographic.build(const [1.0, 2.0, 3.0]), p2);
      expect(Geographic.build(const [1.0, 2.0, 4.0]), isNot(p3));
      expect(Geographic.build(const [1.0, 2.0, 3.0, 4.0]), p4);

      expect(Geographic.parse('1.0,2.0'), p1);
      expect(Geographic.parse('1.0,2.0,3.0'), p2);
      expect(Geographic.parse('1.0,2.0,4.0', type: Coords.xym), p3);
      expect(Geographic.parse('1.0,2.0,3.0,4.0'), p4);
    });

    test('Equals and hashCode', () {
      final one = 1.0;
      final two = 2.0;
      const p1 = Geographic(lon: 1.0, lat: 2.0, elev: 3.0, m: 4.0);
      final p2 = Geographic(lon: one, lat: 2.0, elev: 3.0, m: 4.0);
      final p3 = Geographic(lon: two, lat: 2.0, elev: 3.0, m: 4.0);
      expect(p1, p2);
      expect(p1, isNot(p3));
      expect(p1.hashCode, p2.hashCode);
      expect(p1.hashCode, isNot(p3.hashCode));
      expect(p1.equals2D(p2), true);
      expect(p1.equals2D(p3), false);
      expect(p1.equals3D(p2), true);
      expect(p1.equals3D(p3), false);

      // copy to
      expect(p1, p1.copyTo(Geographic.create));
      expect(p1, p1.copyTo(Projected.create));
    });

    test('Equals with tolerance', () {
      const p1 = Geographic(lon: 1.0002, lat: 2.0002, elev: 3.002, m: 4.0);
      const p2 = Geographic(lon: 1.0003, lat: 2.0003, elev: 3.003, m: 4.0);
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
      expect(const Geographic(lon: 34.0, lat: 18.2).lon, 34.0);
      expect(const Geographic(lon: -326.0, lat: 18.2).lon, 34.0);
      expect(const Geographic(lon: 394.0, lat: 18.2).lon, 34.0);
      expect(const Geographic(lon: -180.0, lat: 18.2).lon, -180.0);
      expect(const Geographic(lon: -181.0, lat: 18.2).lon, 179.0);
      expect(const Geographic(lon: -541.0, lat: 18.2).lon, 179.0);
      expect(const Geographic(lon: 180.0, lat: 18.2).lon, -180.0);
      expect(const Geographic(lon: 181.0, lat: 18.2).lon, -179.0);
      expect(const Geographic(lon: 541.0, lat: 18.2).lon, -179.0);
      expect(const Geographic(lon: 34.2, lat: -90.0).lat, -90.0);
      expect(const Geographic(lon: 34.2, lat: -91.0).lat, -90.0);
      expect(const Geographic(lon: 34.2, lat: 90.0).lat, 90.0);
      expect(const Geographic(lon: 34.2, lat: 91.0).lat, 90.0);
    });

    test('Copy with', () {
      expect(
        const Geographic(lon: 1.0, lat: 1.0).copyWith(),
        const Geographic(lon: 1.0, lat: 1.0),
      );
      expect(
        const Geographic(lon: 1.0, lat: 1.0).copyWith(y: 2.0),
        const Geographic(lon: 1.0, lat: 2.0),
      );
      expect(
        const Geographic(lon: 1.0, lat: 1.0).copyWith(z: 2.0),
        const Geographic(lon: 1.0, lat: 1.0, elev: 2.0),
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

    test('createFromObject', () {
      final li4 = [1, 2, 3, 4];
      const p4 = Projected(x: 1, y: 2, z: 3, m: 4);

      expect(
        Position.createFromObject(p4, to: Projected.create),
        p4,
      );
      expect(
        Position.createFromObject(p4, to: Projected.create, type: Coords.xy),
        Projected.build(const [1, 2]),
      );
      expect(
        Position.createFromObject(p4, to: Projected.create, type: Coords.xyz),
        Projected.build(const [1, 2, 3]),
      );
      expect(
        Position.createFromObject(p4, to: Projected.create, type: Coords.xym),
        Projected.build(const [1, 2, 4], type: Coords.xym),
      );
      expect(
        Position.createFromObject(p4, to: Projected.create, type: Coords.xyzm),
        Projected.build(const [1, 2, 3, 4]),
      );

      expect(
        Position.createFromObject(li4, to: Projected.create),
        p4,
      );
      expect(
        Position.createFromObject(li4, to: Projected.create, type: Coords.xy),
        Projected.build(const [1, 2]),
      );
      expect(
        Position.createFromObject(li4, to: Projected.create, type: Coords.xyz),
        Projected.build(const [1, 2, 3]),
      );
      expect(
        Position.createFromObject(
          const [1, 2, 4],
          to: Projected.create,
          type: Coords.xym,
        ),
        Projected.build(const [1, 2, 4], type: Coords.xym),
      );
      expect(
        Position.createFromObject(li4, to: Projected.create, type: Coords.xyzm),
        Projected.build(const [1, 2, 3, 4]),
      );
    });
  });
}

void _testCoordinateOrder(String text, Iterable<num> coords, [Coords? type]) {
  final factories = [Projected.create, Geographic.create];

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
  }
}

@immutable
class _TestXYZM implements Projected {
  const _TestXYZM({
    required this.x,
    required this.y,
    required this.z,
    required this.m,
  });

  const _TestXYZM.create({required num x, required num y, num? z, num? m})
      : this(x: x, y: y, z: z ?? 0, m: m ?? 0);

  @override
  R copyTo<R extends Position>(CreatePosition<R> factory) =>
      factory.call(x: x, y: y, z: z, m: m);

  @override
  Projected copyWith({num? x, num? y, num? z, num? m}) => _TestXYZM(
        x: x ?? this.x,
        y: y ?? this.y,
        z: z ?? this.z,
        m: m ?? this.m,
      );

  @override
  Projected transform(TransformPosition transform) => transform(this);

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
  int get spatialDimension => type.spatialDimension;

  @override
  int get coordinateDimension => type.coordinateDimension;

/*
  @override
  bool get isGeographic => false;
*/

  @override
  bool get is3D => true;

  @override
  bool get isMeasured => true;

  @override
  Coords get type => Coords.select(
        is3D: is3D,
        isMeasured: isMeasured,
      );

  @override
  String toString() => '$x,$y,$z,$m';

  @override
  bool equals2D(Position other, {num? toleranceHoriz}) =>
      Position.testEquals2D(this, other, toleranceHoriz: toleranceHoriz);

  @override
  bool equals3D(
    Position other, {
    num? toleranceHoriz,
    num? toleranceVert,
  }) =>
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
