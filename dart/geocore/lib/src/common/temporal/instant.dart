// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

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
