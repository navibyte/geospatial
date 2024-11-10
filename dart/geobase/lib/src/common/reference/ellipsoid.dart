// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: constant_identifier_names

import 'package:meta/meta.dart';

/// A reference ellipsoid with ellipsoidal parameters (a, b and f).
///
/// See also Wikipedia about
/// [Earth ellipsoid](https://en.wikipedia.org/wiki/Earth_ellipsoid).
@immutable
class Ellipsoid {
  /// The id (*short name*) of a reference ellisoid.
  final String id;

  /// The name (*ellipse name*) of a reference ellisoid.
  final String name;

  /// The *semi-major axis* (*equatorial radius*) of a reference ellipsoid.
  final double a;

  /// The *semi-minor axis* (*polar radius*) of a reference ellipsoid.
  final double b;

  /// The *flattening* of a reference ellipsoid.
  final double f;

  /// A reference ellipsoid with ellipsoidal parameters (a, b and f).
  const Ellipsoid({
    required this.id,
    required this.name,
    required this.a,
    required this.b,
    required this.f,
  });

  /// Ellisoidal parameters for the `WGS84` (World Geodetic System 1984)
  /// reference ellipsoid.
  ///
  /// See also Wikipedia about
  /// [World Geodetic System](https://en.wikipedia.org/wiki/World_Geodetic_System).
  static const WGS84 = Ellipsoid(
    id: 'WGS84',
    name: 'WGS 84',
    a: 6378137.0,
    b: 6356752.314245,
    f: 1.0 / 298.257223563,
  );

  /// Ellisoidal parameters for the `GRS80` (Geodetic Reference System 1980)
  /// reference ellipsoid.
  ///
  /// See also Wikipedia about
  /// [Geodetic Reference System 1980](https://en.wikipedia.org/wiki/Geodetic_Reference_System_1980).
  static const GRS80 = Ellipsoid(
    id: 'GRS80',
    name: 'GRS 1980(IUGG, 1980)',
    a: 6378137.0,
    b: 6356752.314140,
    f: 1.0 / 298.257222101, // more accurate: 1.0 / 298.257222100882711243
  );

  @override
  String toString() {
    return '$a,$b,$f';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ellipsoid && a == other.a && b == other.b && f == other.f);

  @override
  int get hashCode => Object.hash(a, b, f);
}
