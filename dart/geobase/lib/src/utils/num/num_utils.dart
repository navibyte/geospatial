// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

final _splitByWhitespace = RegExp(r'\s+');

/// Uses `String.toStringAsFixed()` when [n] contains decimals.
///
/// For example returns '15' if a double value is 15.00, and '15.50' if a double
/// value is 15.50.
///
/// See: https://stackoverflow.com/questions/39958472/dart-numberformat
String toStringAsFixedWhenDecimals(num n, int fractionDigits) =>
    n.toStringAsFixed(n.truncateToDouble() == n ? 0 : fractionDigits);

/// Returns a lazy iterable parsing values from [text] separated by [delimiter].
///
/// If [delimiter] is not provided, values are separated by whitespace.
///
/// Throws `FormatException` if cannot parse. Lazy iteration may also throw.
///
/// If [text] contains less than [minCount] value items, then `FormatException``
/// is also thrown.
Iterable<num> parseNumValuesFromText(
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
Iterable<num?> parseNullableNumValuesFromText(
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
Iterable<int> parseIntValuesFromText(
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
