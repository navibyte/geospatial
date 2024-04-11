// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/common/codes/coords.dart';
import '/src/utils/coord_type.dart';

import 'box.dart';
import 'position.dart';
import 'position_series.dart';

List<double> _requireLen(List<double> list, int len) {
  if (list.length != len) {
    throw FormatException('double list lenght must be $len');
  }
  return list;
}

/// A helper extension on `List<double>` to handle coordinate values.
extension CoordinateArrayExtension on List<double> {
  /// A bounding box with coordinate values as a view backed by `this`.
  ///
  /// Supported values combinations:
  /// * minX, minY, maxX, maxY
  /// * minX, minY, minZ, maxX, maxY, maxZ
  /// * minX, minY, minZ, minM, maxX, maxY, maxZ, maxM
  ///
  /// Or for geographic coordinates:
  /// * west, south, east, north
  /// * west, south, minElev, east, north, maxElev
  /// * west, south, minElev, minM, east, north, maxElev, maxM
  ///
  /// See [Box.view] for more information.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0)
  /// [10.0, 20.0, 15.0, 25.0].box;
  ///
  /// // a 3D box (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0)
  /// [10.0, 20.0, 30.0, 15.0, 25.0, 35.0].box;
  ///
  /// // a measured 3D box
  /// // (x: 10.0 .. 15.0, y: 20.0 .. 25.0, z: 30.0 .. 35.0, m: 40.0 .. 45.0)
  /// [10.0, 20.0, 30.0, 40.0, 15.0, 25.0, 35.0, 45.0].box;
  /// ```
  Box get box => Box.view(this, type: Coords.fromDimension(length ~/ 2));

  /// A position with coordinate values as a view backed by `this`.
  ///
  /// Supported values combinations: (x, y), (x, y, z) and (x, y, z, m).
  ///
  /// Or for geographic coordinates (lon, lat), (lon, lat, elev) and
  /// (lon, lat, elev, m).
  ///
  /// See [Position.view] for more information.
  ///
  /// See also [xy], [xyz], [xym] and [xyzm].
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D position (x: 10.0, y: 20.0)
  /// [10.0, 20.0].position;
  ///
  /// // a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// [10.0, 20.0, 30.0].position;
  ///
  /// // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// [10.0, 20.0, 30.0, 40.0].position;
  /// ```
  Position get position =>
      Position.view(this, type: Coords.fromDimension(length));

  /// Coordinate values of geospatial positions as a view backed by `this`.
  ///
  /// The [type] parameter defines the cooordinate type of coordinate values as
  /// a flat structure.
  ///
  /// See [PositionSeries.view] for more information.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a series of 2D positions (with values of the `Coords.xy` type)
  /// [
  ///   10.0, 20.0, // (x, y) for position 0
  ///   12.5, 22.5, // (x, y) for position 1
  ///   15.0, 25.0, // (x, y) for position 2
  /// ].positions(Coords.xy);
  ///
  /// // a series of 3D positions (with values of the `Coords.xyz` type)
  /// [
  ///   10.0, 20.0, 30.0, // (x, y, z) for position 0
  ///   12.5, 22.5, 32.5, // (x, y, z) for position 1
  ///   15.0, 25.0, 35.0, // (x, y, z) for position 2
  /// ].positions(Coords.xyz);
  ///
  /// // a series of measured 2D positions (values of the `Coords.xym` type)
  /// [
  ///   10.0, 20.0, 40.0, // (x, y, m) for position 0
  ///   12.5, 22.5, 42.5, // (x, y, m) for position 1
  ///   15.0, 25.0, 45.0, // (x, y, m) for position 2
  /// ].positions(Coords.xym);
  ///
  /// // a series of measured 3D positions (values of the `Coords.xyzm` type)
  /// [
  ///   10.0, 20.0, 30.0, 40.0, // (x, y, z, m) for position 0
  ///   12.5, 22.5, 32.5, 42.5, // (x, y, z, m) for position 1
  ///   15.0, 25.0, 35.0, 45.0, // (x, y, z, m) for position 2
  /// ].positions(Coords.xyzm);
  /// ```
  PositionSeries positions([Coords type = Coords.xy]) =>
      PositionSeries.view(this, type: type);

  /// A position with x and y coordinates as a view backed by `this`.
  ///
  /// The double list represented by `this` must contain `x, y` values in
  /// this order (or `lon, lat` for geographic coordinates).
  ///
  /// See [Position.view] for more information. See also [position].
  ///
  /// Throws FormatException if this does not contain exactly 2 values.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 2D position (x: 10.0, y: 20.0)
  /// [10.0, 20.0].xy;
  /// ```
  Position get xy => Position.view(_requireLen(this, 2));

  /// A position with x, y and z coordinates as a view backed by `this`.
  ///
  /// The double list represented by `this` must contain `x, y, z` values in
  /// this order (or `lon, lat, elev` for geographic coordinates).
  ///
  /// See [Position.view] for more information. See also [position].
  ///
  /// Throws FormatException if this does not contain exactly 3 values.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a 3D position (x: 10.0, y: 20.0, z: 30.0)
  /// [10.0, 20.0, 30.0].xyz;
  /// ```
  Position get xyz => Position.view(_requireLen(this, 3), type: Coords.xyz);

  /// A position with x, y and m coordinates as a view backed by `this`.
  ///
  /// The double list represented by `this` must contain `x, y, m` values in
  /// this order (or `lon, lat, m` for geographic coordinates).
  ///
  /// See [Position.view] for more information. See also [position].
  ///
  /// Throws FormatException if this does not contain exactly 3 values.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a measured 2D position (x: 10.0, y: 20.0, m: 40.0)
  /// [10.0, 20.0, 40.0].xym;
  /// ```
  Position get xym => Position.view(_requireLen(this, 3), type: Coords.xym);

  /// A position with x, y, z and m coordinates as a view backed by `this`.
  ///
  /// The double list represented by `this` must contain `x, y, z, m` values in
  /// this order (or `lon, lat, elev, m` for geographic coordinates).
  ///
  /// See [Position.view] for more information. See also [position].
  ///
  /// Throws FormatException if this does not contain exactly 4 values.
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a measured 3D position (x: 10.0, y: 20.0, z: 30.0, m: 40.0)
  /// [10.0, 20.0, 30.0, 40.0].xyzm);
  /// ```
  Position get xyzm => Position.view(_requireLen(this, 4), type: Coords.xyzm);
}

/// A helper extension on `Iterable<Position>`.
extension PositionArrayExtension on Iterable<Position> {
  /// Returns positions of this `Position` iterable as `PositionSeries`.
  ///
  /// The coordinate type a returned array is set to the coordinate type of the
  /// first position of this iterable.
  ///
  /// If this iterable is empty, then returned array is empty too (with
  /// coordinate type set to `Coords.xy`).
  ///
  /// Examples:
  ///
  /// ```dart
  /// // a series of 2D positions
  /// [
  ///   Position.create(x: 10.0, y: 20.0),
  ///   Position.create(x: 12.5, y: 22.5),
  ///   Position.create(x: 15.0, y: 25.0),
  /// ].series(),
  ///
  /// // a series of 3D positions
  /// [
  ///   Position.create(x: 10.0, y: 20.0, z: 30.0),
  ///   Position.create(x: 12.5, y: 22.5, z: 32.5),
  ///   Position.create(x: 15.0, y: 25.0, z: 35.0),
  /// ].series(),
  ///
  /// // a series of measured 2D positions
  /// [
  ///   Position.create(x: 10.0, y: 20.0, m: 40.0),
  ///   Position.create(x: 12.5, y: 22.5, m: 42.5),
  ///   Position.create(x: 15.0, y: 25.0, m: 45.0),
  /// ].series(),
  ///
  /// // a series of measured 3D positions
  /// [
  ///   Position.create(x: 10.0, y: 20.0, z: 30.0, m: 40.0),
  ///   Position.create(x: 12.5, y: 22.5, z: 32.5, m: 42.5),
  ///   Position.create(x: 15.0, y: 25.0, z: 35.0, m: 45.0),
  /// ].series(),
  /// ```
  PositionSeries series() => isEmpty
      ? PositionSeries.empty()
      : PositionSeries.from(
          this,
          type: positionArrayType(this),
        );

  /// A string representation of coordinate values of all positions (in this
  /// iterable) separated by [delimiter].
  ///
  /// If [positionDelimiter] is given, then positions are separated by
  /// [positionDelimiter] and coordinate values inside positions by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// If [compactNums] is true, any ".0" postfixes of numbers without fraction
  /// digits are stripped.
  ///
  /// Set [swapXY] to true to print y (or latitude) before x (or longitude).
  String toText({
    String delimiter = ',',
    String? positionDelimiter = ',',
    int? decimals,
    bool compactNums = true,
    bool swapXY = false,
  }) {
    final buf = StringBuffer();
    writeValues(
      buf,
      delimiter: delimiter,
      positionDelimiter: positionDelimiter,
      decimals: decimals,
      compactNums: compactNums,
      swapXY: swapXY,
    );
    return buf.toString();
  }

  /// Writes coordinate values of all positions (in this iterable) to [buffer]
  /// separated by [delimiter].
  ///
  /// If [positionDelimiter] is given, then positions are separated by
  /// [positionDelimiter] and coordinate values inside positions by [delimiter].
  ///
  /// Use [decimals] to set a number of decimals (not applied if no decimals).
  ///
  /// If [compactNums] is true, any ".0" postfixes of numbers without fraction
  /// digits are stripped.
  ///
  /// Set [swapXY] to true to print y (or latitude) before x (or longitude).
  void writeValues(
    StringSink buffer, {
    String delimiter = ',',
    String? positionDelimiter,
    int? decimals,
    bool compactNums = true,
    bool swapXY = false,
  }) {
    var isFirst = true;
    for (final pos in this) {
      // write separator between positions
      if (isFirst) {
        isFirst = false;
      } else {
        buffer.write(positionDelimiter ?? delimiter);
      }

      // write coordinate values of a position
      Position.writeValues(
        pos,
        buffer,
        delimiter: delimiter,
        decimals: decimals,
        compactNums: compactNums,
        swapXY: swapXY,
      );
    }
  }
}

/// A helper extension on `Iterable<Box?>`.
extension BoxArrayExtension on Iterable<Box?> {
  /// Returns a single minimum bounding box containing all non-null boxes on
  /// this.
  ///
  /// Returns null if this iterable is empty.
  Box? merge() {
    Box? merged;
    for (final box in this) {
      if (box != null) {
        merged = merged == null ? box : merged.merge(box);
      }
    }
    return merged;
  }
}
