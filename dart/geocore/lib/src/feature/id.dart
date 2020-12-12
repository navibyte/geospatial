// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';
import 'package:fixnum/fixnum.dart';

import 'package:equatable/equatable.dart';

/// An identifier for a geospatial feature, represented as `String` or `Int64`.
abstract class FeatureId {
  const FeatureId();

  factory FeatureId.of(dynamic id) = FeatureIdBase;

  /// True if this feature id is stored as a string.
  bool isString();

  /// True if this feature id is stored as an integer.
  bool isInt();

  /// This id as a `Int64` value or null if cannot be represented as such.
  ///
  /// `Int64` from the fixnum package is used to ensure compatibility of
  /// handling large integers both on Dart VM and JavaScript compiled runtimes.
  Int64? tryInt64();

  /// This id as a String.
  @override
  String toString();
}

@immutable
class FeatureIdBase extends FeatureId with EquatableMixin {
  FeatureIdBase(this.id);

  final dynamic id;

  @override
  bool isString() => id is String;

  @override
  bool isInt() => id is Int64 || id is int;

  @override
  Int64? tryInt64() {
    if (id is Int64) {
      return id;
    } else if (id is int) {
      return Int64(id);
    } else if (id is String) {
      try {
        return Int64.parseInt(id);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  String toString() => id.toString();

  @override
  List<Object?> get props => [id];
}
