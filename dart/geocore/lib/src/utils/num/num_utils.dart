// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Uses `String.toStringAsFixed()` when [n] contains decimals.
/// 
/// For example returns '15' if a double value is 15.00, and '15.50' if a double
/// value is 15.50.
/// 
/// See: https://stackoverflow.com/questions/39958472/dart-numberformat
String toStringAsFixedWhenDecimals(num n, int fractionDigits) =>
    n.toStringAsFixed(n.truncateToDouble() == n ? 0 : fractionDigits);
