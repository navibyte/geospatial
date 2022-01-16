// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'temporal.dart';

/// An instant with a timestamp.
abstract class Instant extends Temporal {
  /// Creates an instant with a [time] stamp.
  factory Instant(DateTime time) = _InstantDateTime;

  /// Creates an instant from a string.
  ///
  /// The input [text] must be formatted according to RFC 3339. See
  /// `DateTime.parse` for reference of valid inputs.
  ///
  /// Throws FormatException if an instant cannot be parsed.
  factory Instant.parse(String text) = _InstantDateTime.parse;

  /// Creates an instant from a string or returns null if cannot parse.
  ///
  /// The input [text] must be formatted according to RFC 3339. See
  /// `DateTime.parse` for reference of valid inputs.
  static Instant? tryParse(String text) => _InstantDateTime.tryParse(text);

  /// The time stamp of this instant.
  DateTime get time;

  @override
  Instant toUtc();
}

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

@immutable
class _InstantDateTime with EquatableMixin implements Instant {
  const _InstantDateTime(this.time);

  factory _InstantDateTime.parse(String text) =>
      _InstantDateTime(DateTime.parse(text));

  static Instant? tryParse(String text) {
    final t = DateTime.tryParse(text);
    return t != null ? _InstantDateTime(t) : null;
  }

  @override
  final DateTime time;

  @override
  List<Object?> get props => [time];

  @override
  bool get isUtc => time.isUtc;

  @override
  Instant toUtc() => isUtc ? this : _InstantDateTime(time.toUtc());

  @override
  String toString() => time.toIso8601String();

  @override
  bool isAfterTime(DateTime timestamp) => time.isAfter(timestamp);

  @override
  bool isBeforeTime(DateTime timestamp) => time.isBefore(timestamp);
}
