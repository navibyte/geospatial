// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:math';

import 'package:meta/meta.dart';

@internal
double cosh(double x) {
  // The hyperbolic cosine function is defined as:
  // cosh(x) = (e^x + e^-x) / 2

  return (exp(x) + exp(-x)) / 2;
}

@internal
double acosh(double x) {
  // The inverse hyperbolic cosine function is defined as:
  // acosh(x) = ln(x + sqrt(x^2 - 1))

  return log(x + sqrt(x * x - 1));
}

@internal
double sinh(double x) {
  // The hyperbolic sine function is defined as:
  // sinh(x) = (e^x - e^-x) / 2

  return (exp(x) - exp(-x)) / 2;
}

@internal
double asinh(double x) {
  // The inverse hyperbolic sine function is defined as:
  // asinh(x) = ln(x + sqrt(x^2 + 1))

  return log(x + sqrt(x * x + 1));
}

@internal
double tanh(double x) {
  // The hyperbolic tangent function is defined as:
  // tanh(x) = (e^x - e^-x) / (e^x + e^-x)

  final expX = exp(x);
  final expNegX = exp(-x);
  return (expX - expNegX) / (expX + expNegX);
}

@internal
double atanh(double x) {
  // The inverse hyperbolic tangent function is defined as:
  // atanh(x) = 0.5 * ln((1 + x) / (1 - x))

  return 0.5 * log((1 + x) / (1 - x));
}
