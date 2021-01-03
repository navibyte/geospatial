// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:intl/intl.dart';

import 'exceptions.dart';

/// Converts [value] to `String` or throws FormatException if cannot convert.
String valueToString(dynamic value) {
  if (value == null) {
    throw NullValueException();
  }
  if (value is String) {
    return value;
  } else {
    return value.toString();
  }
}

/// Converts [value] to `int` or throws FormatException if cannot convert.
///
/// If provided [min] and [max] are used to clamp the returned value.
int valueToInt(dynamic value, {int? min, int? max}) {
  if (value == null) {
    throw NullValueException();
  }
  int result;
  if (value is int) {
    result = value;
  } else if (value is BigInt) {
    result = value.toInt();
  } else if (value is double) {
    result = value.round();
  } else if (value is String) {
    result = _stringToInt(value);
  } else if (value is bool) {
    result = value ? 1 : 0;
  } else {
    throw ConversionException(target: int, data: value);
  }
  if (min != null && result < min) {
    result = min;
  }
  if (max != null && result > max) {
    result = max;
  }
  return result;
}

/// Converts [value] to `BigInt` or throws FormatException if cannot convert.
///
/// If provided [min] and [max] are used to clamp the returned value.
BigInt valueToBigInt(dynamic value, {BigInt? min, BigInt? max}) {
  if (value == null) {
    throw NullValueException();
  }
  BigInt result;
  if (value is BigInt) {
    result = value;
  } else if (value is int) {
    result = BigInt.from(value);
  } else if (value is double) {
    result = BigInt.from(value);
  } else if (value is String) {
    result = BigInt.parse(value);
  } else if (value is bool) {
    result = value ? BigInt.one : BigInt.zero;
  } else {
    throw ConversionException(target: BigInt, data: value);
  }
  if (min != null && result < min) {
    result = min;
  }
  if (max != null && result > max) {
    result = max;
  }
  return result;
}

/// Converts [value] to `double` or throws FormatException if cannot convert.
///
/// If provided [min] and [max] are used to clamp the returned value.
double valueToDouble(dynamic value, {double? min, double? max}) {
  if (value == null) {
    throw NullValueException();
  }
  double result;
  if (value is double) {
    result = value;
  } else if (value is int) {
    result = value.toDouble();
  } else if (value is BigInt) {
    result = value.toDouble();
  } else if (value is String) {
    result = double.parse(value);
  } else if (value is bool) {
    result = value ? 1.0 : 0.0;
  } else {
    throw ConversionException(target: double, data: value);
  }
  if (min != null && result < min) {
    result = min;
  }
  if (max != null && result > max) {
    result = max;
  }
  return result;
}

/// Converts [value] to `bool` or throws FormatException if cannot convert.
bool valueToBool(dynamic value) {
  if (value == null) {
    throw NullValueException();
  }
  if (value is bool) {
    return value;
  } else if (value is int) {
    return value != 0;
  } else if (value is BigInt) {
    return value.toInt() != 0;
  } else if (value is double) {
    return value.round() != 0;
  } else if (value is String) {
    switch (value) {
      case '':
      case 'false':
      case '0':
        return false;
      case 'true':
      case '1':
        return true;
    }
  }
  throw ConversionException(target: bool, data: value);
}

/// Converts the [value] to a `DateTime` value.
///
/// The returned time is ensured to be in the UTC time zone.
///
/// If the [value] is already a `DateTime` then it is returned (UTC ensured).
///
/// If the [value] is String then DateTime.parse is used in parsing. Or if
/// [sourceFormat] (and optionally [isUTCSource] too) is given, then that format
/// instance is used in parsing.
///
/// Otherwise a FormatException is thrown.
DateTime valueToTimeUTC(dynamic value,
    {DateFormat? sourceFormat, bool isUTCSource = false}) {
  if (value == null) {
    throw NullValueException();
  } else if (value is DateTime) {
    return value.toUtc();
  } else if (value is String) {
    if (sourceFormat == null) {
      // "The function parses a subset of ISO 8601 which includes the subset
      // accepted by RFC 3339."
      return DateTime.parse(value).toUtc();
    } else {
      return sourceFormat.parse(value, isUTCSource).toUtc();
    }
  }
  throw ConversionException(target: DateTime, data: value);
}

/// Converts the [value] to a `DateTime` value.
///
/// The returned time is ensured to be in the UTC time zone.
///
/// If the [value] is already a `DateTime` then it is returned (UTC ensured).
///
/// If the [value] is int then
/// DateTime.fromMillisecondsSinceEpoch is used in parsing.
///
/// If the [value] is String then it is parsed to int and
/// DateTime.fromMillisecondsSinceEpoch is used in parsing.
///
/// Otherwise a FormatException is thrown.
DateTime valueToTimeMillisUTC(dynamic value, {bool isUTCSource = false}) {
  if (value == null) {
    throw NullValueException();
  } else if (value is DateTime) {
    return value.toUtc();
  } else if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: isUTCSource)
        .toUtc();
  } else if (value is String) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(value),
            isUtc: isUTCSource)
        .toUtc();
  }
  throw ConversionException(target: DateTime, data: value);
}

int _stringToInt(String value) {
  return int.tryParse(value) ?? double.parse(value).round();
}
