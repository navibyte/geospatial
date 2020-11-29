// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

double valueToDouble(dynamic value, {double? min, double? max}) {
  if (value == null) {
    throw FormatException('Cannot convert null.');
  }
  double result;
  if (value is double) {
    result = value;
  } else if (value is int) {
    result = value.toDouble();
  } else if (value is String) {
    result = double.parse(value);
  } else if (value is bool) {
    result = value ? 1.0 : 0.0;
  } else {
    throw FormatException('Cannot convert $value.');
  }
  if (min != null && result < min) {
    result = min;
  }
  if (max != null && result > max) {
    result = max;
  }
  return result;
}
