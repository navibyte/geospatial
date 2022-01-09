// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A base class for *temporal* events like *instants* and *intervals*.
abstract class Temporal {
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
  String toText();

  /// Returns true if this *temporal* event occurs fully after [instant].
  ///
  /// See `DateTime.isAfter` for reference.
  bool isAfterTime(DateTime instant);

  /// Returns true if this occurs fully before [instant].
  ///
  /// See `DateTime.isAfter` for reference.
  bool isBeforeTime(DateTime instant);

  /*
  todo:
      bool isAfter(Temporal other);
      bool isBefore(Temporal other);
      bool anyInteracts(Temporal other);
      ...
  */
}
