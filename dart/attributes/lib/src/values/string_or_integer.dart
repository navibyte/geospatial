// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An interface for a value representing `String`, `int` or `BigInt` data.
///
/// The optimal situation for representing integers would be just to use `int`.
/// For Dart 2 it's 64 bit integer on VM enviroment. However in web enviroment
/// (compiled with dart2js) it supports "all integers between -2^53 and 2^53,
/// and some integers with larger magnitude". So for this reason also `BigInt`
/// might be needed for storing integers out of that range.
abstract class StringOrInteger {
  const StringOrInteger();

  /// True if this value is stored as a String.
  ///
  /// Even if false is returned it might be possible to access value as String.
  bool get isString;

  /// True if this value is stored as an integer (`int` or `BigInt`) value.
  ///
  /// Even if false is returned it might be possible to access value as integer.
  bool get isInteger;

  /// True if this value is stored as `int`.
  ///
  /// Even if false is returned it might be possible to access value as int.
  bool get isInt;

  /// True if this value is stored  as `BigInt`.
  ///
  /// Even if false is returned it might be possible to access value as BigInt.
  bool get isBigInt;

  /// Returns this value as a `String` value.
  ///
  /// FormatException is thrown if an underlying value cannot be converted to
  /// String.
  String asString();

  /// Returns this value as a `int` value.
  ///
  /// FormatException is thrown if an underlying value cannot be converted to
  /// int.
  ///
  /// On web enviroment (compiled with dart2js) `int` can store "all integers
  /// between -2^53 and 2^53, and some integers with larger magnitude".
  int asInt();

  /// Returns this value as a `BigInt` value.
  ///
  /// FormatException is thrown if an underlying value cannot be converted to
  /// BigInt.
  BigInt asBigInt();

  /// This value as a `String` value or null if cannot be converted to `String`.
  String? tryAsString();

  /// This value as a `int` value or null if cannot be converted to `int`.
  ///
  /// On web enviroment (compiled with dart2js) `int` can store "all integers
  /// between -2^53 and 2^53, and some integers with larger magnitude".
  int? tryAsInt();

  /// This value as a `BigInt` value or null if cannot be converted to `BigInt`.
  BigInt? tryAsBigInt();
}
