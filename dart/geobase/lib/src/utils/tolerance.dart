// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

/// Asserts that [tolerance] is null or positive (>= 0).
@internal
void assertTolerance(num? tolerance) {
  assert(
    tolerance == null || tolerance >= 0.0,
    'Tolerance must be null or positive (>= 0)',
  );
}
