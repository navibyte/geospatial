// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// The default epsilon value `1.0e-9` used as a tolerance in `equals2D`,
/// `equals3D` and similar methods in this package.
///
/// NOTE: this value can be still adjusted to meet general geospatial use cases
/// considering different coordinate types and accuracy requirements.
///
/// See also [doublePrecisionEpsilon] and
/// [decimal degree precision](https://en.wikipedia.org/wiki/Decimal_degrees).
const double defaultEpsilon = 1.0e-9;

/// The maximum relative precision of double numbers (IEEE 754).
///
/// The constant value can be calculated as `pow(2, -52) as double`.
///
/// See the Wikipedia article about
/// [Machine epsilon](https://en.wikipedia.org/wiki/Machine_epsilon).
const double doublePrecisionEpsilon = 2.220446049250313e-16;
