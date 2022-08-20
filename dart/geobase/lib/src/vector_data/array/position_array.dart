// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'coordinates.dart';

/// Coordinate values of geospatial positions as an iterable collection.
///
/// The collection implements `Iterable<double>` with coordinate values of
/// positions as a flat structure (each position containing  2, 3, or 4 values).
///
/// Position data is also accessible as position coordinates via [data]. You can
/// also use [dataTo] to map coordinate values to custom position types.
///
/// See [Position] for description about supported coordinate values.
abstract class PositionArray with _CoordinatesMixin {
  @override
  final Iterable<double> _data;

  @override
  final Coords _type;

  /// Positions with coordinate values of [type] from [source].
  const PositionArray(Iterable<double> source, {Coords type = Coords.xy})
      : _data = source,
        _type = type;

  /// Positions with coordinate values as a view backed by [source].
  ///
  /// The [source] collection contains coordinate values of positions as a flat
  /// structure. For example for `Coords.xyz` the first three coordinate values
  /// are x, y and z of the first position, the next three coordinate values are
  /// x, y and z of the second position, and so on.
  ///
  /// The `type.coordinateDimension` (either 2, 3 or 4) property defines the
  /// number of coordinate values for each position. The number of positions
  /// contained by the view is calculated as
  /// `source.length ~/ type.coordinateDimension`. If there are zero values or
  /// less coordinate values than `type.coordinateDimension`, then the view is
  /// considered empty.
  ///
  /// An iterable collection of [source] may be represented by a [List] or any
  /// [Iterable] with efficient `length` and `elementAt` implementations. A lazy
  /// iterable with a lot of coordinate values may produce very poor
  /// performance.
  ///
  /// See [Position] for description about supported coordinate values.
  factory PositionArray.view(Iterable<double> source, {Coords type}) =
      _PositionArrayImpl.view;

  /// Parses positions with coordinate values from [text].
  ///
  /// Coordinate values in [text] are separated by [delimiter].
  ///
  /// Throws FormatException if coordinates are invalid.
  factory PositionArray.parse(
    String text, {
    Pattern? delimiter = ',',
    Coords type = Coords.xy,
  }) =>
      PositionArray.view(
        parseDoubleValues(text, delimiter: delimiter).toList(growable: false),
        type: type,
      );

  /// Access coordinate values of positions.
  ///
  /// See [Position] for description about supported coordinate values.
  PositionData<PositionCoords, double> get data =>
      _PositionArrayData<PositionCoords>(_data, _type, PositionCoords.view);

  /// Access positions as custom type of [T].
  ///
  /// The [factory] is used to create instances of [T] as needed.
  PositionData<T, double> dataTo<T extends Position>(
    CreatePosition<T> factory,
  ) =>
      _PositionArrayData<T>(_data, _type, _adapt(factory));

  _CreateAt<T> _adapt<T extends Position>(CreatePosition<T> factory) {
    return (Iterable<double> coordinates, {required Coords type}) {
      return Position.buildPosition(coordinates, to: factory, type: type);
    };
  }

  /// Access position array as projected positions.
  PositionData<Projected, double> get toProjected =>
      _PositionArrayData<Projected>(_data, _type, Projected.build);

  /// Access position array as geographic positions.
  PositionData<Geographic, double> get toGeographic =>
      _PositionArrayData<Geographic>(_data, _type, Geographic.build);

  /// Returns a new position array with all positions projected using
  /// [projection].
  PositionArray project(Projection projection) => PositionArray.view(
        projection.projectCoords(_data, type: _type),
        type: _type,
      );
}

@immutable
class _PositionArrayImpl extends PositionArray {
  const _PositionArrayImpl.view(super.source, {super.type = Coords.xy})
      : super();

  @override
  bool operator ==(Object other) =>
      other is _PositionArrayImpl &&
      _type == other._type &&
      _data == other._data;

  @override
  int get hashCode => Object.hash(_type, _data);

  // Note: calculating equality and hashCode of Iterable<double> arrays is
  // delegated to viewed source iterable (most often lists).
  //
  // The default List: "Lists are, by default, only equal to themselves. Even if
  // other is also a list, the equality comparison does not compare the elements
  // of the two lists."
  //
  // So when two position arrays view on two different List<double> lists with
  // exactly same value in same order, this implementation returns false on
  // equality.
  //
  // Some other Iterable<double> or List<double> implementations might use
  // something like IterableEquality.equals / hash from "collection" package.
  //
  // Anyway, a position array might be really large, so calculating equality and
  // hash might then have performance issues too.
}

class _PositionArrayData<E extends Position> with PositionData<E, double> {
  final Iterable<double> data;

  @override
  final Coords type;

  final _CreateAt<E> factory;

  const _PositionArrayData(this.data, this.type, this.factory);

  @override
  int get length => data.length ~/ coordinateDimension;

  @override
  E operator [](int index) {
    final dim = coordinateDimension;
    final start = index * dim;
    final end = start + dim;
    return _doCreateRange(
      data,
      to: factory,
      type: type,
      start: start,
      end: end,
    );
  }

  @override
  R get<R extends Position>(int index, {required CreatePosition<R> to}) =>
      Position.buildPosition(
        data,
        offset: index * coordinateDimension,
        to: to,
        type: type,
      );

  @override
  double x(int index) => data.elementAt(index * coordinateDimension);

  @override
  double y(int index) => data.elementAt(index * coordinateDimension + 1);

  @override
  double z(int index) =>
      type.is3D ? data.elementAt(index * coordinateDimension + 2) : 0.0;

  @override
  double? optZ(int index) =>
      type.is3D ? data.elementAt(index * coordinateDimension + 2) : null;

  @override
  double m(int index) {
    final mIndex = type.indexForM;
    return mIndex != null
        ? data.elementAt(index * coordinateDimension + mIndex)
        : 0.0;
  }

  @override
  double? optM(int index) {
    final mIndex = type.indexForM;
    return mIndex != null
        ? data.elementAt(index * coordinateDimension + mIndex)
        : null;
  }

  @override
  int get spatialDimension => type.spatialDimension;

  @override
  int get coordinateDimension => type.coordinateDimension;

  @override
  bool get is3D => type.is3D;

  @override
  bool get isMeasured => type.isMeasured;

  @override
  Iterable<E> get all sync* {
    final dim = coordinateDimension;
    final len = data.length;
    var start = 0;
    var end = dim;
    while (end <= len) {
      yield _doCreateRange(
        data,
        to: factory,
        type: type,
        start: start,
        end: end,
      );
      start += dim;
      end += dim;
    }
  }
}
