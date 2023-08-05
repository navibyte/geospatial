// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print

import 'package:geobase/coordinates.dart';
import 'package:test/test.dart';

void expectScaled2i(
  Scalable2i actual,
  Scalable2i expected, {
  num? tol,
}) {
  final equals = actual.equals2D(
    expected,
    toleranceHoriz: tol ?? 0.0000001,
  );
  if (!equals || actual.zoom != expected.zoom) {
    print('"$actual" not equals to "$expected"');
  }
  expect(equals, isTrue);
}
