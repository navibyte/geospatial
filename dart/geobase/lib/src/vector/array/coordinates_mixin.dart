// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'coordinates.dart';

mixin _CoordinatesMixin implements Coordinates {
  Iterable<double> get _data;
  Coords get _type;

  // ---------------------------------------------------------------------------
  // Positionable implementation

  /// The coordinate type of coordinates values in this view.
  @override
  Coords get type => _type;

  @override
  int get spatialDimension => _type.spatialDimension;

  @override
  int get coordinateDimension => _type.coordinateDimension;

  @override
  bool get is3D => _type.is3D;

  @override
  bool get isMeasured => _type.isMeasured;

  // ---------------------------------------------------------------------------
  // Iterable<double> implementation

  @override
  double elementAt(int index) => _data.elementAt(index);

  @override
  int get length => _data.length;

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  double get single => _data.single;

  @override
  Iterator<double> get iterator => _data.iterator;

  @override
  bool any(bool Function(double element) test) => _data.any(test);

  @override
  Iterable<R> cast<R>() => _data.cast<R>();

  @override
  bool contains(Object? element) => _data.contains(element);

  @override
  bool every(bool Function(double element) test) => _data.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(double element) toElements) =>
      _data.expand<T>(toElements);

  @override
  double get first => _data.first;

  @override
  double firstWhere(
    bool Function(double element) test, {
    double Function()? orElse,
  }) =>
      _data.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(
    T initialValue,
    T Function(T previousValue, double element) combine,
  ) =>
      _data.fold<T>(initialValue, combine);

  @override
  Iterable<double> followedBy(Iterable<double> other) =>
      _data.followedBy(other);

  @override
  void forEach(void Function(double element) action) => _data.forEach(action);

  @override
  String join([String separator = '']) => _data.join(separator);

  @override
  double get last => _data.last;

  @override
  double lastWhere(
    bool Function(double element) test, {
    double Function()? orElse,
  }) =>
      _data.lastWhere(test, orElse: orElse);

  @override
  Iterable<T> map<T>(T Function(double e) toElement) => _data.map<T>(toElement);

  @override
  double reduce(double Function(double value, double element) combine) =>
      _data.reduce(combine);

  @override
  double singleWhere(
    bool Function(double element) test, {
    double Function()? orElse,
  }) =>
      _data.singleWhere(test, orElse: orElse);

  @override
  Iterable<double> skip(int count) => _data.skip(count);

  @override
  Iterable<double> skipWhile(bool Function(double value) test) =>
      _data.skipWhile(test);

  @override
  Iterable<double> take(int count) => _data.take(count);

  @override
  Iterable<double> takeWhile(bool Function(double value) test) =>
      _data.takeWhile(test);

  @override
  List<double> toList({bool growable = true}) =>
      _data.toList(growable: growable);

  @override
  Set<double> toSet() => _data.toSet();

  @override
  Iterable<double> where(bool Function(double element) test) =>
      _data.where(test);

  @override
  Iterable<T> whereType<T>() => _data.whereType();
}
