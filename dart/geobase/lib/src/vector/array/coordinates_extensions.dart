// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

//import '/src/codes/coords.dart';
import '/src/coordinates/base/box.dart';
import '/src/coordinates/base/position.dart';
import '/src/coordinates/geographic/geobox.dart';
import '/src/coordinates/geographic/geographic.dart';
import '/src/coordinates/projected/projbox.dart';
import '/src/coordinates/projected/projected.dart';

import 'coordinates.dart';

/// A helper extension on `Iterable<Position>` to convert data as
/// [PositionArray].
@Deprecated('Deprecated as PositionArray is deprecated')
extension PositionIterableCoordinatesExtension on Iterable<Position> {
  /// Returns positions of this `Position` iterable as `PositionArray`
  /// structuring coordinates a flat structure of `double` iterable.
  ///
  /// The coordinate type a returned array is set to the coordinate type of the
  /// first position of this iterable.
  ///
  /// If this iterable is empty, then returned array is empty too (with
  /// coordinate type set to `Coords.xy`).
  @Deprecated('Deprecated as PositionArray is deprecated')
  PositionArray array() {
    final len = length;
    if (len == 0) {
      return PositionArray.view([]);
    }
    final type = first.type;
    final dim = type.coordinateDimension;
    final data = List<double>.filled(len * dim, 0.0);
    var posIndex = 0;
    for (final pos in this) {
      for (var coordIndex = 0; coordIndex < dim; coordIndex++) {
        data[posIndex * dim + coordIndex] = pos[coordIndex];
      }
      posIndex++;
    }
    return PositionArray.view(data, type: type);
  }
}

/// A helper extension on [Position] to convert position objects between
/// subtypes like [Projected], [Geographic] and [PositionCoords].
@Deprecated('Deprecated as PositionCoords is deprecated')
extension PositionCoordinatesExtension on Position {
  /// Returns this position as an instance of [PositionCoords].
  ///
  /// The coordinate type defined by [type] is preserved.
  ///
  /// If the type of the position is [PositionCoords], then this is returned.
  /// Otherwise a new instance with copied coordinate values is created.
  @Deprecated('Deprecated as PositionCoords is deprecated')
  PositionCoords get coords {
    final pos = this;
    return pos is PositionCoords ? pos : pos.copyTo(PositionCoords.create);
  }

  /// Returns this position as an instance of [Projected].
  ///
  /// The coordinate type defined by [type] is preserved.
  ///
  /// If the type of the position is [Projected], then this is returned.
  /// Otherwise a new instance with copied coordinate values is created.
  @Deprecated('Deprecated as PositionCoords is deprecated')
  Projected get asProjected {
    final pos = this;
    return pos is Projected ? pos : pos.copyTo(Projected.create);
  }

  /// Returns this position as an instance of [Geographic].
  ///
  /// The coordinate type defined by [type] is preserved.
  ///
  /// If the type of the position is [Geographic], then this is returned.
  /// Otherwise a new instance with copied coordinate values is created.
  @Deprecated('Deprecated as PositionCoords is deprecated')
  Geographic get asGeographic {
    final pos = this;
    return pos is Geographic ? pos : pos.copyTo(Geographic.create);
  }
}

/// A helper extension on [Box] to convert position objects between
/// subtypes like [ProjBox], [GeoBox] and [BoxCoords].
@Deprecated('Deprecated as BoxCoords is deprecated')
extension BoxCoordinatesExtension on Box {
  /// Returns this bounding box as an instance of [BoxCoords].
  ///
  /// The coordinate type defined by [type] is preserved.
  ///
  /// If the type of the box is [BoxCoords], then this is returned.
  /// Otherwise a new instance with copied coordinate values is created.
  @Deprecated('Deprecated as BoxCoords is deprecated')
  BoxCoords get coords {
    final box = this;
    return box is BoxCoords ? box : box.copyTo(BoxCoords.create);
  }

  /// Returns this bounding box as an instance of [ProjBox].
  ///
  /// The coordinate type defined by [type] is preserved.
  ///
  /// If the type of the box is [ProjBox], then this is returned.
  /// Otherwise a new instance with copied coordinate values is created.
  @Deprecated('Deprecated as BoxCoords is deprecated')
  ProjBox get asProjected {
    final box = this;
    return box is ProjBox ? box : box.copyTo(ProjBox.create);
  }

  /// Returns this bounding box as an instance of [GeoBox].
  ///
  /// The coordinate type defined by [type] is preserved.
  ///
  /// If the type of the box is [GeoBox], then this is returned.
  /// Otherwise a new instance with copied coordinate values is created.
  @Deprecated('Deprecated as BoxCoords is deprecated')
  GeoBox get asGeographic {
    final box = this;
    return box is GeoBox ? box : box.copyTo(GeoBox.create);
  }
}
