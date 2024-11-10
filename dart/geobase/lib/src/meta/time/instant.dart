// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'temporal.dart';

/// An instant with a timestamp.
@immutable
class Instant extends Temporal {
  final DateTime _time;

  /// Creates an instant with a [time] stamp.
  const Instant(DateTime time) : _time = time;

  /// Creates an instant from a string.
  ///
  /// The input [text] must be formatted according to RFC 3339. See
  /// `DateTime.parse` for reference of valid inputs.
  ///
  /// Throws FormatException if an instant cannot be parsed.
  factory Instant.parse(String text) => Instant(DateTime.parse(text));

  /// Creates an instant from a string or returns null if cannot parse.
  ///
  /// The input [text] must be formatted according to RFC 3339. See
  /// `DateTime.parse` for reference of valid inputs.
  static Instant? tryParse(String text) {
    final t = DateTime.tryParse(text);
    return t != null ? Instant(t) : null;
  }

  /// The time stamp of this instant.
  DateTime get time => _time;

  /// Copy this instant with an optional [time] changed.
  Instant copyWith({DateTime? time}) => time != null ? Instant(time) : this;

  @override
  bool get isUtc => time.isUtc;

  @override
  Instant toUtc() => isUtc ? this : Instant(time.toUtc());

  @override
  bool isAfterTime(DateTime time) => this.time.isAfter(time);

  @override
  bool isBeforeTime(DateTime time) => this.time.isBefore(time);

  @override
  String toString() => time.toIso8601String();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Instant && time == other.time);

  @override
  int get hashCode => time.hashCode;
}
