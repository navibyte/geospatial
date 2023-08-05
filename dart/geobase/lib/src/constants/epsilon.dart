// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// The maximum relative precision of double numbers (IEEE 754).
///
/// The constant value can be calculated as `pow(2, -52) as double`.
///
/// See the Wikipedia article about
/// [Machine epsilon](https://en.wikipedia.org/wiki/Machine_epsilon).
const double doublePrecisionEpsilon = 2.220446049250313e-16;
