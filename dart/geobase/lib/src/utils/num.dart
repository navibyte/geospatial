// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

final _splitByWhitespace = RegExp(r'\s+');

/// Uses `String.toStringAsFixed()` when [n] contains decimals.
///
/// For example returns '15' if a double value is 15.00, and '15.50' if a double
/// value is 15.50.
///
/// See: https://stackoverflow.com/questions/39958472/dart-numberformat
@internal
String toStringAsFixedWhenDecimals(num n, int fractionDigits) =>
    n.toStringAsFixed(n.truncateToDouble() == n ? 0 : fractionDigits);

/// Returns [n] in as compact form as possible if [compact] is true.
///
/// If [compact] is false, then simply `n.toString()` is returned.
///
/// Otherwise:
///
/// If [n] is `int` then an integer as a string is returned.
///
/// If [n] is `double` without decimals then it's returned without decimals, not
/// even ".0" postfix.
///
/// If [n] is `double` with decimals then it's returned with decimals as the
/// standard method `n.toString()` formats it.
///
/// Examples:
/// * int (15) => "15"
/// * double (15.0) => "15"
/// * double (15.1) => "15.1"
/// * double (15.123) => "15.123"
@internal
String toStringCompact(num n, {bool compact = true}) {
  if (!compact || n is int) {
    return n.toString();
  } else {
    final nt = n.truncateToDouble();
    return nt == n ? n.toStringAsFixed(0) : n.toString();
  }
}

/// Returns a lazy iterable parsing values from [text] separated by [delimiter].
///
/// If [delimiter] is not provided, values are separated by whitespace.
///
/// Throws `FormatException` if cannot parse. Lazy iteration may also throw.
///
/// If [text] contains less than [minCount] value items, then `FormatException``
/// is also thrown.
@internal
Iterable<num> parseNumValues(
  String text, {
  Pattern? delimiter,
  int minCount = 2,
}) {
  // check argumemts
  if (delimiter == '') throw const FormatException('Invalid delimiter');
  // split by delimiter and checks that there are enough items
  final parts = text.trim().split(delimiter ?? _splitByWhitespace);
  if (parts.length < minCount) {
    throw const FormatException('Too few value items');
  }
  // returns lazy iterable for num values, iteration steps may throw
  // FormatException (by double.parse).
  return parts.map<num>((value) => double.parse(value.trim()));
}

/// Returns a lazy iterable parsing values from [text] separated by [delimiter].
///
/// Empty value items on [text] are returned as null.
///
/// If [delimiter] is not provided, values are separated by whitespace.
///
/// Throws `FormatException` if cannot parse. Lazy iteration may also throw.
///
/// If [text] contains less than [minCount] value items, then `FormatException``
/// is also thrown.
@internal
Iterable<num?> parseNullableNumValues(
  String text, {
  Pattern? delimiter,
  int minCount = 2,
}) {
  // check argumemts
  if (delimiter == '') throw const FormatException('Invalid delimiter');
  // split by delimiter and checks that there are enough items
  final parts = text.trim().split(delimiter ?? _splitByWhitespace);
  if (parts.length < minCount) {
    throw const FormatException('Too few value items');
  }
  // returns lazy iterable for num? values, iteration steps may throw
  // FormatException (by double.parse). Empty coords are converted to null.
  return parts
      .map<num?>((value) => value.isEmpty ? null : double.parse(value.trim()));
}

/// Returns a lazy iterable parsing values from [text] separated by [delimiter].
///
/// If [delimiter] is not provided, values are separated by whitespace.
///
/// Throws `FormatException` if cannot parse. Lazy iteration may also throw.
///
/// If [text] contains less than [minCount] value items, then `FormatException``
/// is also thrown.
@internal
Iterable<int> parseIntValues(
  String text, {
  Pattern? delimiter,
  int minCount = 2,
}) {
  // check argumemts
  if (delimiter == '') throw const FormatException('Invalid delimiter');
  // split by delimiter and checks that there are enough items
  final parts = text.trim().split(delimiter ?? _splitByWhitespace);
  if (parts.length < minCount) {
    throw const FormatException('Too few value items');
  }
  // returns lazy iterable for int values, iteration steps may throw
  // FormatException (by double.parse).
  return parts.map<int>((value) {
    value = value.trim();
    return int.tryParse(value) ?? double.parse(value).round();
  });
}

/// Returns a lazy iterable parsing values from [text] separated by [delimiter].
///
/// If [delimiter] is not provided, values are separated by whitespace.
///
/// Throws `FormatException` if cannot parse. Lazy iteration may also throw.
///
/// If [text] contains less than [minCount] value items, then `FormatException``
/// is also thrown.
@internal
Iterable<double> parseDoubleValues(
  String text, {
  Pattern? delimiter,
  int minCount = 2,
}) {
  // check argumemts
  if (delimiter == '') throw const FormatException('Invalid delimiter');
  // split by delimiter and checks that there are enough items
  final parts = text.trim().split(delimiter ?? _splitByWhitespace);
  if (parts.length < minCount) {
    throw const FormatException('Too few value items');
  }
  // returns lazy iterable for double values, iteration steps may throw
  // FormatException (by double.parse).
  return parts.map<double>((value) => double.parse(value.trim()));
}
