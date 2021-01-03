// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import '../values.dart';

/// An identifier of something, represented as `String`, `int` or `BigInt`.
abstract class Identifier implements StringOrInteger {
  const Identifier();

  /// An identifier from [id] that MUST be either `String`, `int` or `BigInt`.
  ///
  /// Please note that for production runtimes the id is not validated even if
  /// for development environment assertions apply checking for correct types.
  ///
  /// You may want to use [fromString], [fromInt] or [fromBigInt] to ensure
  /// better type safety if id type is known statically.
  factory Identifier.from(Object id) => _IdentifierBase(id);

  /// An identifier from [id] of the type `String`.
  factory Identifier.fromString(String id) => _IdentifierBase(id);

  /// An identifier from [id] of the type `int`.
  ///
  /// On web enviroment (compiled with dart2js) `int` can store "all integers
  /// between -2^53 and 2^53, and some integers with larger magnitude".
  factory Identifier.fromInt(int id) => _IdentifierBase(id);

  /// An identifier from [id] of the type `BigInt`.
  factory Identifier.fromBigInt(BigInt id) => _IdentifierBase(id);

  /// Prepares a nullable [Identifier] instance of the given [id]
  ///
  /// The [id] argument  is allowed to be null or an instance of [Identifier],
  /// `String`, `int` or `BigInt`. In other cases an ArgumentError is thrown.
  static Identifier? idOrNull(dynamic id) =>
      id == null || id is Identifier ? id : Identifier.from(id);
}

/// Private implementation of [Identifier].
/// The implementation may change in future.
@immutable
class _IdentifierBase extends Identifier with EquatableMixin {
  const _IdentifierBase(this.storage)
      : assert(storage is String || storage is int || storage is BigInt);

  /// The stored id as a `String`, `int` or `BigInt` value.
  final Object storage;

  @override
  bool get isString => storage is String;

  @override
  bool get isInteger => storage is BigInt || storage is int;

  @override
  bool get isInt => storage is int;

  @override
  bool get isBigInt => storage is BigInt;

  @override
  String asString() => storage.toString();

  @override
  int asInt() {
    final id = storage;
    if (id is int) {
      return id;
    } else if (id is BigInt) {
      final clamped = id.toInt();
      if (id != BigInt.from(clamped)) {
        throw FormatException('$id cannot be clamped to int');
      }
      return clamped;
    } else {
      return int.parse(id.toString());
    }
  }

  @override
  BigInt asBigInt() {
    final id = storage;
    if (id is BigInt) {
      return id;
    } else if (id is int) {
      return BigInt.from(id);
    } else {
      return BigInt.parse(id.toString());
    }
  }

  @override
  String? tryAsString() {
    try {
      return asString();
    } on FormatException {
      return null;
    }
  }

  @override
  int? tryAsInt() {
    try {
      return asInt();
    } on FormatException {
      return null;
    }
  }

  @override
  BigInt? tryAsBigInt() {
    try {
      return asBigInt();
    } on FormatException {
      return null;
    }
  }

  @override
  String toString() => storage.toString();

  @override
  List<Object?> get props => [storage];
}
