// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'dart:collection';

import 'package:meta/meta.dart';

/// A base interface for a series (list) of items of type [T].
abstract class Series<T> implements Iterable<T> {
  const Series();

  /// Create an unmodifiable [Series] backed by [source].
  factory Series.view(Iterable<T> source) = SeriesView<T>;

  /// Create an immutable [Series] copied from [elements].
  factory Series.from(Iterable<T> elements) =>
      Series<T>.view(List<T>.unmodifiable(elements));

  /// Returns an item of the type T at [index].
  ///
  /// Throws RangeError if [index] is out of bounds.
  T operator [](int index);
}

/// An unmodifiable [Series] backed by another list.
@immutable
class SeriesView<T> extends UnmodifiableListView<T> implements Series<T> {
  /// Create an unmodifiable [SeriesView] backed by [source].
  SeriesView(Iterable<T> source) : super(source);
}
