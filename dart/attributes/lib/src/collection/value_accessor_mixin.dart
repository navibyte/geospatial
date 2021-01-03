// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../values.dart';

import 'value_accessor.dart';

/// A mixin implementing all but three of the methods of [ValueAccessor].
///
/// Sub classes should implement at least missing `int get length`,
/// `Iterable<K> get keys` and `dynamic operator [](K key)` methods.
mixin ValueAccessorMixin<K> implements ValueAccessor<K> {
  @override
  bool exists(K key) => keys.contains(key);

  @override
  bool hasNull(K key) => exists(key) && this[key] == null;

  @override
  String getString(K key) => valueToString(this[key]);

  @override
  int getInt(K key, {int? min, int? max}) =>
      valueToInt(this[key], min: min, max: max);

  @override
  BigInt getBigInt(K key, {BigInt? min, BigInt? max}) =>
      valueToBigInt(this[key], min: min, max: max);

  @override
  double getDouble(K key, {double? min, double? max}) =>
      valueToDouble(this[key], min: min, max: max);

  @override
  bool getBool(K key) => valueToBool(this[key]);

  /// Returns a value located at [key] as a `DateTime` value of UTC.
  ///
  /// The returned time must be in the UTC time zone.
  ///
  /// If the value is not already represented as a `DateTime` then the default
  /// implementation converts a value using `DateTime.parse` method that "parses
  /// a subset of ISO 8601 which includes the subset accepted by RFC 3339."
  ///
  /// However classes implementing [ValueAccessor] should override this default
  /// implementation as needed (as encoding time differs in different formats).
  ///
  /// FormatException is thrown if an underlying value is unavailable or
  /// cannot be converted to DateTime.
  @override
  DateTime getTimeUTC(K key) => valueToTimeUTC(this[key]);

  @override
  String? tryString(K key) {
    try {
      return getString(key);
    } on FormatException {
      return null;
    }
  }

  @override
  int? tryInt(K key, {int? min, int? max}) {
    try {
      return getInt(key, min: min, max: max);
    } on FormatException {
      return null;
    }
  }

  @override
  BigInt? tryBigInt(K key, {BigInt? min, BigInt? max}) {
    try {
      return getBigInt(key, min: min, max: max);
    } on FormatException {
      return null;
    }
  }

  @override
  double? tryDouble(K key, {double? min, double? max}) {
    try {
      return getDouble(key, min: min, max: max);
    } on FormatException {
      return null;
    }
  }

  @override
  bool? tryBool(K key) {
    try {
      return getBool(key);
    } on FormatException {
      return null;
    }
  }

  /// Returns a value located at [key] as a `DateTime` value of UTC or null.
  ///
  /// The returned time must be in the UTC time zone.
  ///
  /// If the value is not already represented as a `DateTime` then the default
  /// implementation converts a value using `DateTime.parse` method that "parses
  /// a subset of ISO 8601 which includes the subset accepted by RFC 3339."
  ///
  /// However classes implementing [ValueAccessor] should override this default
  /// implementation as needed (as encoding time differs in different formats).
  ///
  /// `null` is returned if an underlying value is unavailable or cannot be
  /// converted to DateTime.
  @override
  DateTime? tryTimeUTC(K key) {
    try {
      return getTimeUTC(key);
    } on FormatException {
      return null;
    }
  }
}
