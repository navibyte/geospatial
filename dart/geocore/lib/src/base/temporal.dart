// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base.dart';

/// An instant with a time stamp.
@immutable
class Instant with EquatableMixin {
  /// Creates an instant with a [time] stamp.
  const Instant(this.time);

  /// Creates an instant from a string.
  ///
  /// The input [text] must be formatted according to RFC 3339. See
  /// `DateTime.parse` for reference of valid inputs.
  ///
  /// Throws FormatException if an interval cannot be parsed.
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
  final DateTime time;

  @override
  List<Object?> get props => [time];
}

/// An interval with start and end time stamps (one or both can be null = open).
@immutable
class Interval with EquatableMixin {
  /// Creates a closed interval with [start] and [end] time stamps.
  const Interval.closed(this.start, this.end);

  /// Creates an open ended interval with the [start] time stamp.
  const Interval.openEnd(this.start) : end = null;

  /// Creates an open started interval with the [end] time stamp.
  const Interval.openStart(this.end) : start = null;

  /// Creates a fully open interval with [start] and [end] set to null.
  const Interval.open()
      : start = null,
        end = null;

  /// An interval of a string the list of [parts] (length must be exactly 2).
  ///
  /// Start and end time stamps must be formatted according to RFC 3339. See
  /// `DateTime.parse` for reference of valid inputs for start and end parts.
  ///
  /// For other lengths than 2 an ArgumentError is thrown.
  ///
  /// Throws FormatException if an interval cannot be parsed.
  factory Interval.fromJson(Iterable<Object?> parts) {
    if (parts.length == 2) {
      final start = parts.elementAt(0) as String?;
      final end = parts.elementAt(1) as String?;
      if (start == null || start.isEmpty || start == '..') {
        if (end == null || end.isEmpty || end == '..') {
          return const Interval.open();
        } else {
          return Interval.openStart(DateTime.parse(end));
        }
      } else if (end == null || end.isEmpty || end == '..') {
        return Interval.openEnd(DateTime.parse(start));
      } else {
        return Interval.closed(DateTime.parse(start), DateTime.parse(end));
      }
    }
    throw ArgumentError.value(parts, '');
  }

  /// An interval of a string ('../end', 'start/..' or 'start/end').
  ///
  /// Start and end time stamps must be formatted according to RFC 3339. See
  /// `DateTime.parse` for reference of valid inputs for start and end parts.
  ///
  /// Throws FormatException if an interval cannot be parsed.
  factory Interval.parse(String text) {
    final parts = text.split('/');
    if (parts.length == 2) {
      return Interval.fromJson(<String>[parts[0], parts[1]]);
    }
    throw FormatException('Invalid interval "$text".');
  }

  /// An interval of a string ('../end', 'start/..' or 'start/end').
  ///
  /// Start and end time stamps must be formatted according to RFC 3339. See
  /// `DateTime.parse` for reference of valid inputs for start and end parts.
  ///
  /// Returns null if an interval cannot be parsed.
  static Interval? tryParse(String text) {
    try {
      return Interval.parse(text);
    } on Exception {
      return null;
    }
  }

  /// The start time of the interval. If null then the interval is open started.
  final DateTime? start;

  /// The end time of the interval. If null then the interval is open ended.
  final DateTime? end;

  /// A duration (difference) between [start] and [end] if both are available.
  Duration? get duration {
    final s = start;
    final e = end;
    return s != null && e != null ? e.difference(s) : null;
  }

  /// True if the interval is open (both [start] and [end] are null).
  bool get isOpen => start == null && end == null;

  /// True if the interval is closed (both [start] and [end] are non null).
  bool get isClosed => start != null && end != null;

  @override
  List<Object?> get props => [start, end];
}
