// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';

/// A function to create an object of [T] from [coordinates] of [type].
@internal
typedef CreateAt<T> = T Function(
  Iterable<double> coordinates, {
  required Coords type,
});

/// Create an object of [T] from a subset (indicated [start] and [end]) of
/// [coordinates] of [type].
///
/// An object of [T] is created using the factory function [to].
@internal
T doCreateRange<T>(
  Iterable<double> coordinates, {
  required CreateAt<T> to,
  required Coords type,
  required int start,
  required int end,
}) {
  if (coordinates is List<double>) {
    // the source coordinates is a List, get range
    return to.call(
      coordinates.getRange(start, end),
      type: type,
    );
  } else {
    // the source is not a List, generate a new
    return to.call(
      coordinates.skip(start).take(end - start).toList(growable: false),
      type: type,
    );
  }
}
