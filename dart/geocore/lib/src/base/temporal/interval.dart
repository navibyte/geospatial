// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'instant.dart';
import 'temporal.dart';

/// An interval between optional `start` and `end` instants.
///
/// An interval can be closed (both start and end set), open (both start and
/// end are not set), open ended (only start) or open started (only end).
///
/// Intervals include the start instant and exclude the end instant.
abstract class Interval extends Temporal {
  /// An interval between optional [start] (inclusive) and [end] (exclusive).
  factory Interval(Instant? start, Instant? end) = _IntervalImpl;

  /// A closed interval between [start] (inclusive) and [end] (exclusive).
  factory Interval.closed(DateTime start, DateTime end) = _IntervalImpl.closed;

  /// An open ended interval starting from the [start] instant (inclusive).
  factory Interval.openEnd(DateTime start) = _IntervalImpl.openEnd;

  /// Creates an open started interval ending to the [end] instant (exclusive).
  factory Interval.openStart(DateTime end) = _IntervalImpl.openStart;

  /// A fully open interval with `start` and `end` set to null.
  factory Interval.open() = _IntervalImpl.open;

  /// Creates an interval from [data] containing two String? items (start, end).
  ///
  /// Start and end instants must be formatted according to RFC 3339. See
  /// `DateTime.parse` for reference of valid inputs for start and end parts.
  ///
  /// Throws FormatException if an interval cannot be parsed.
  factory Interval.fromData(Iterable<Object?> data) = _IntervalImpl.fromData;

  /// An interval of a string ("../<end>", "<start>/.." or "<start>/<end>").
  ///
  /// Start and end instants must be formatted according to RFC 3339. See
  /// `DateTime.parse` for reference of valid inputs for start and end parts.
  ///
  /// Throws FormatException if an interval cannot be parsed.
  factory Interval.parse(String text) = _IntervalImpl.parse;

  /// An interval of a string ("../<end>", "<start>/.." or "<start>/<end>").
  ///
  /// Start and end instants must be formatted according to RFC 3339. See
  /// `DateTime.parse` for reference of valid inputs for start and end parts.
  ///
  /// Returns null if an interval cannot be parsed.
  static Interval? tryParse(String text) => _IntervalImpl.tryParse(text);

  /// The start instant, or `null` if the interval is open started.
  Instant? get start;

  /// The end instant, or `null` if the the interval is open ended.
  Instant? get end;

  /// The start instant as DateTime, or `null` if the interval is open started.
  DateTime? get startTime;

  /// The end instant as DateTime, or `null` if the the interval is open ended.
  DateTime? get endTime;

  /// A duration (difference) between `start` and `end]` if both are available.
  Duration? get duration;

  /// True if the interval is open (both `start` and `end` are null).
  bool get isOpen;

  /// True if the interval is closed (both `start` and `end` are non null).
  bool get isClosed;

  @override
  Interval toUtc();
}

// -----------------------------------------------------------------------------
// Private implementation code below.
// The implementation may change in future.

@immutable
class _IntervalImpl with EquatableMixin implements Interval {
  @override
  final Instant? start;

  @override
  final Instant? end;

  const _IntervalImpl(this.start, this.end);

  const _IntervalImpl.open()
      : start = null,
        end = null;

  factory _IntervalImpl.closed(DateTime startTime, DateTime endTime) =>
      _IntervalImpl(Instant(startTime), Instant(endTime));

  factory _IntervalImpl.openEnd(DateTime startTime) =>
      _IntervalImpl(Instant(startTime), null);

  factory _IntervalImpl.openStart(DateTime endTime) =>
      _IntervalImpl(null, Instant(endTime));

  factory _IntervalImpl.fromData(Iterable<Object?> data) {
    if (data.length == 2) {
      final start = data.elementAt(0);
      final end = data.elementAt(1);
      if ((start is String?) && (end is String?)) {
        if (start == null || start.isEmpty || start == '..') {
          if (end == null || end.isEmpty || end == '..') {
            return const _IntervalImpl.open();
          } else {
            return _IntervalImpl.openStart(DateTime.parse(end));
          }
        } else if (end == null || end.isEmpty || end == '..') {
          return _IntervalImpl.openEnd(DateTime.parse(start));
        } else {
          return _IntervalImpl.closed(
            DateTime.parse(start),
            DateTime.parse(end),
          );
        }
      }
    }
    throw const FormatException('Cannot parse interval.');
  }

  factory _IntervalImpl.parse(String text) {
    final parts = text.split('/');
    if (parts.length == 2) {
      return _IntervalImpl.fromData(<String>[parts[0], parts[1]]);
    }
    throw FormatException('Invalid interval "$text".');
  }

  static _IntervalImpl? tryParse(String text) {
    try {
      return _IntervalImpl.parse(text);
    } on Exception {
      return null;
    }
  }

  @override
  DateTime? get startTime => start?.time;

  @override
  DateTime? get endTime => end?.time;

  @override
  Duration? get duration {
    final s = startTime;
    final e = endTime;
    return s != null && e != null ? e.difference(s) : null;
  }

  @override
  bool get isOpen => startTime == null && endTime == null;

  @override
  bool get isClosed => startTime != null && endTime != null;

  @override
  List<Object?> get props => [startTime, endTime];

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
  Interval toUtc() =>
      isUtc ? this : _IntervalImpl(start?.toUtc(), end?.toUtc());

  @override
  String toText() {
    final s = start;
    final e = end;
    if (s != null) {
      if (e != null) {
        return '${s.toText()}/${e.toText()}';
      } else {
        return '${s.toText()}/..';
      }
    } else {
      if (e != null) {
        return '../${e.toText()}';
      } else {
        return '../..';
      }
    }
  }

  @override
  bool isAfterTime(DateTime timestamp) =>
      startTime != null && startTime!.isAfter(timestamp);

  @override
  bool isBeforeTime(DateTime timestamp) =>
      // interval's end timestamp is not included in the interval
      endTime != null &&
      (endTime!.isBefore(timestamp) || endTime!.isAtSameMomentAs(timestamp));
}
