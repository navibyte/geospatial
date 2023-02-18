// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'instant.dart';
import 'temporal.dart';

/// An interval between optional `start` and `end` instants.
///
/// An interval can be closed (both start and end set), open (both start and
/// end are not set), open ended (only start) or open started (only end).
///
/// Intervals include the start instant and exclude the end instant.
@immutable
class Interval extends Temporal {
  final Instant? _start;
  final Instant? _end;

  /// An interval between optional [start] (inclusive) and [end] (exclusive).
  const Interval(Instant? start, Instant? end)
      : _start = start,
        _end = end;

  /// A closed interval between [start] (inclusive) and [end] (exclusive).
  factory Interval.closed(DateTime start, DateTime end) =>
      Interval(Instant(start), Instant(end));

  /// An open ended interval starting from the [start] instant (inclusive).
  factory Interval.openEnd(DateTime start) => Interval(Instant(start), null);

  /// Creates an open started interval ending to the [end] instant (exclusive).
  factory Interval.openStart(DateTime end) => Interval(null, Instant(end));

  /// A fully open interval with `start` and `end` set to null.
  const Interval.open() : this(null, null);

  /// Creates an interval from [data] containing two String? items (start, end).
  ///
  /// Start and end instants must be formatted according to RFC 3339. See
  /// `DateTime.parse` for reference of valid inputs for start and end parts.
  ///
  /// Either start or end is considered open, if an item is null, an empty
  /// string, or a string with the value "..".
  ///
  /// Throws FormatException if an interval cannot be parsed.
  factory Interval.fromJson(Iterable<dynamic> data) {
    if (data.length == 2) {
      final start = data.elementAt(0);
      final end = data.elementAt(1);
      if ((start is String?) && (end is String?)) {
        if (start == null || start.isEmpty || start == '..') {
          if (end == null || end.isEmpty || end == '..') {
            return const Interval.open();
          } else {
            return Interval.openStart(DateTime.parse(end));
          }
        } else if (end == null || end.isEmpty || end == '..') {
          return Interval.openEnd(DateTime.parse(start));
        } else {
          return Interval.closed(
            DateTime.parse(start),
            DateTime.parse(end),
          );
        }
      }
    }
    throw const FormatException('Cannot parse interval.');
  }

  /// An interval of a string ("../<end>", "<start>/.." or "<start>/<end>").
  ///
  /// Start and end instants must be formatted according to RFC 3339. See
  /// `DateTime.parse` for reference of valid inputs for start and end parts.
  ///
  /// Throws FormatException if an interval cannot be parsed.
  factory Interval.parse(String text) {
    final parts = text.split('/');
    if (parts.length == 2) {
      return Interval.fromJson([parts[0], parts[1]]);
    }
    throw FormatException('Invalid interval "$text".');
  }

  /// An interval of a string ("../<end>", "<start>/.." or "<start>/<end>").
  ///
  /// Start and end instants must be formatted according to RFC 3339. See
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

  /// The start instant, or `null` if the interval is open started.
  Instant? get start => _start;

  /// The end instant, or `null` if the the interval is open ended.
  Instant? get end => _end;

  /// The start instant as DateTime, or `null` if the interval is open started.
  DateTime? get startTime => _start?.time;

  /// The end instant as DateTime, or `null` if the the interval is open ended.
  DateTime? get endTime => _end?.time;

  /// A duration (difference) between `start` and `end` if both are available.
  Duration? get duration {
    final s = startTime;
    final e = endTime;
    return s != null && e != null ? e.difference(s) : null;
  }

  /// True if the interval is open (both `start` and `end` are null).
  bool get isOpen => startTime == null && endTime == null;

  /// True if the interval is closed (both `start` and `end` are non null).
  bool get isClosed => startTime != null && endTime != null;

  @override
  bool get isUtc {
    final s = start;
    if (s != null && !s.isUtc) {
      return false;
    }
    final e = end;
    if (e != null && !e.isUtc) {
      return false;
    }
    return true;
  }

  @override
  Interval toUtc() => isUtc ? this : Interval(start?.toUtc(), end?.toUtc());

  @override
  String toString() {
    final s = start;
    final e = end;
    if (s != null) {
      if (e != null) {
        return '$s/$e';
      } else {
        return '$s/..';
      }
    } else {
      if (e != null) {
        return '../$e';
      } else {
        return '../..';
      }
    }
  }

  @override
  bool isAfterTime(DateTime time) =>
      startTime != null && startTime!.isAfter(time);

  @override
  bool isBeforeTime(DateTime time) =>
      // interval's end timestamp is not included in the interval
      endTime != null &&
      (endTime!.isBefore(time) || endTime!.isAtSameMomentAs(time));

  @override
  bool operator ==(Object other) =>
      other is Interval &&
      startTime == other.startTime &&
      endTime == other.endTime;

  @override
  int get hashCode => Object.hash(startTime, endTime);
}
