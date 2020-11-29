// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

/// An instant with a time stamp.
@immutable
class Instant with EquatableMixin {
  /// Creates an instant with a [time] stamp.
  const Instant(this.time);

  /// Creates an instant from a string.
  ///
  /// The input [str] must be formatted according to RFC 3339.
  ///
  /// Throws FormatException if an interval cannot be parsed.
  factory Instant.from(String str) {
    return Instant(DateTime.parse(str));
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
  const Interval.closed(DateTime start, DateTime end)
      : start = start,
        end = end;

  /// Creates an open ended interval with the [start] time stamp.
  const Interval.openEnd(DateTime start)
      : start = start,
        end = null;

  /// Creates an open started interval with the [end] time stamp.
  const Interval.openStart(DateTime end)
      : start = null,
        end = end;

  /// Creates a fully open interval with [start] and [end] set to null.
  const Interval.open()
      : start = null,
        end = null;

  /// An interval of a string ('../end', 'start/..' or 'start/end').
  ///
  /// Start and end time stamps must be formatted according to RFC 3339.
  ///
  /// Throws FormatException if an interval cannot be parsed.
  factory Interval.parse(String str) {
    final parts = str.split('/');
    if (parts.length == 2) {
      return Interval.fromJson([parts[0], parts[1]]);
    }
    throw FormatException('Invalid interval "$str".');
  }

  /// An interval of a string the list of [parts] (length must be exactly 2).
  ///
  /// Start and end time stamps must be formatted according to RFC 3339.
  ///
  /// For other lengths than 2 an ArgumentError is thrown.
  ///
  /// Throws FormatException if an interval cannot be parsed.
  factory Interval.fromJson(List parts) {
    if (parts.length == 2) {
      final start = parts[0];
      final end = parts[1];
      if (start == null || start.isEmpty || start == '..') {
        if (end == null || end.isEmpty || end == '..') {
          return Interval.open();
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

  /// The start time of the interval. If null then the interval is open started.
  final DateTime? start;

  /// The end time of the interval. If null then the interval is open ended.
  final DateTime? end;

  /// True if the interval is open (both [start] and [end] are null).
  bool get isOpen => start == null && end == null;

  /// True if the interval is closed (both [start] and [end] are non null).
  bool get isClosed => start != null && end != null;

  @override
  List<Object?> get props => [start, end];
}
