// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'counted.dart';

/// An interface to access typed values from a value map by keys of type [K].
///
/// Normally [K] is either String or int, but could be other types also.
///
/// Implementations should support storing at least following types:
/// String, int, BigInt, double, bool, DateTime, Null.
abstract class ValueAccessor<K> implements Counted {
  const ValueAccessor();

  /// Returns true if the [key] references an existing value, null or non-null.
  bool exists(K key);

  /// Returns [keys] of values as an iterable of [K].
  Iterable<K> get keys;

  /// Returns a dynamic value of any type at [key], result is null or non-null.
  dynamic operator [](K key);

  /// Returns true if a value with [key] exists and that value is null.
  bool hasNull(K key);

  /// Returns a value of `String` type at [key].
  ///
  /// FormatException is thrown if an underlying value is unavailable or
  /// cannot be converted to String.
  String getString(K key);

  /// Returns a value of `int` type at [key].
  ///
  /// If provided [min] and [max] are used to clamp the returned value.
  ///
  /// FormatException is thrown if an underlying value is unavailable or
  /// cannot be converted to int.
  int getInt(K key, {int? min, int? max});

  /// Returns a value of `BigInt` type at [key].
  ///
  /// If provided [min] and [max] are used to clamp the returned value.
  ///
  /// FormatException is thrown if an underlying value is unavailable or
  /// cannot be converted to BigInt.
  BigInt getBigInt(K key, {BigInt? min, BigInt? max});

  /// Returns a value of `double` type at [key].
  ///
  /// If provided [min] and [max] are used to clamp the returned value.
  ///
  /// FormatException is thrown if an underlying value is unavailable or
  /// cannot be converted to double.
  double getDouble(K key, {double? min, double? max});

  /// Returns a value of `bool` type at [key].
  ///
  /// FormatException is thrown if an underlying value is unavailable or
  /// cannot be converted to bool.
  bool getBool(K key);

  /// Returns a located at [key] as a `DateTime` value of UTC.
  ///
  /// The returned time must be in the UTC time zone.
  ///
  /// FormatException is thrown if an underlying value is unavailable or
  /// cannot be converted to DateTime.
  DateTime getTimeUTC(K key);

  /// Returns a value of `String` type at [key] or null if missing.
  ///
  /// `null` is returned if an underlying value is unavailable or cannot be
  /// converted to String.
  String? tryString(K key);

  /// Returns a value of `int` type at [key] or null if missing.
  ///
  /// If provided [min] and [max] are used to clamp the returned value.
  ///
  /// `null` is returned if an underlying value is unavailable or cannot be
  /// converted to int.
  int? tryInt(K key, {int? min, int? max});

  /// Returns a value of `BigInt` type at [key] or null if missing.
  ///
  /// If provided [min] and [max] are used to clamp the returned value.
  ///
  /// `null` is returned if an underlying value is unavailable or cannot be
  /// converted to BigInt.
  BigInt? tryBigInt(K key, {BigInt? min, BigInt? max});

  /// Returns a value of `double` type at [key] or null if missing.
  ///
  /// If provided [min] and [max] are used to clamp the returned value.
  ///
  /// `null` is returned if an underlying value is unavailable or cannot be
  /// converted to double.
  double? tryDouble(K key, {double? min, double? max});

  /// Returns a value of `bool` type at [key] or null if missing.
  ///
  /// `null` is returned if an underlying value is unavailable or cannot be
  /// converted to bool.
  bool? tryBool(K key);

  /// Returns a value located at [key] as a `DateTime` value of UTC or null.
  ///
  /// The returned time must be in the UTC time zone.
  ///
  /// `null` is returned if an underlying value is unavailable or cannot be
  /// converted to DateTime.
  DateTime? tryTimeUTC(K key);
}
