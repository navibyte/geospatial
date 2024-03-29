// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A base class for *temporal* objects like *instants* and *intervals*.
abstract class Temporal {
  /// Default `const` constructor to allow extending this abstract class.
  const Temporal();

  /// True if this *temporal* object is set to UTC time.
  bool get isUtc;

  /// Returns this *temporal* object in the UTC time zone.
  Temporal toUtc();

  /// A string representation of this *temporal* object.
  ///
  /// If object is an *instant*, returns ISO-8601 full-precision extended format
  /// representation. See `DateTime.toIso8601String()` for reference.
  ///
  /// If object is an interval, returns a string defined as (where "<start>"
  /// and "<end>" refers to ISO-8601 formatted timestamps):
  /// * closed interval: "<start>/<end>"
  /// * open ended interval: "<start>/.."
  /// * open started interval: "../<end>"
  /// * open interval: "../.."
  @override
  String toString();

  /// Returns true if this occurs fully after [time].
  ///
  /// See `DateTime.isAfter` for reference.
  bool isAfterTime(DateTime time);

  /// Returns true if this occurs fully before [time].
  ///
  /// See `DateTime.isAfter` for reference.
  bool isBeforeTime(DateTime time);

  /*
  todo:
      bool isAfter(Temporal other);
      bool isBefore(Temporal other);
      bool anyInteracts(Temporal other);
      ...
  */
}
