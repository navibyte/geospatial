// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

/// Asserts that [tolerance] is positive (>= 0).
@internal
void assertTolerance(double tolerance) {
  assert(
    tolerance >= 0.0,
    'Tolerance positive (>= 0)',
  );
}
