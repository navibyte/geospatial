// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

/// Optional configuration parameters for encoding and decoding WKB.
class WkbConf with EquatableMixin {
  /// When true, geometries decoded and detected as "empty" are built with
  /// `emptyGeometry` method of content builder.
  ///
  /// If this is false (as it is by default) geometries detected as "empty" are
  /// built with content methods specific to geometries. For example an empty
  /// point (NaN, NaN) via `point` method and an empty line string (with 0
  /// points) via `lineString` method.
  final bool buildEmptyGeometries;

  /// When true, child geometries are encoded with same coordinate type as their
  /// geometry collection.
  ///
  /// This is applied only when encoding WKB binary data.
  final bool forceCoordTypeOfItemsOnGeometryCollection;

  /// Optional configuration parameters for encoding and decoding WKB.
  const WkbConf({
    this.buildEmptyGeometries = false,
    this.forceCoordTypeOfItemsOnGeometryCollection = false,
  });

  @override
  List<Object?> get props => [
        buildEmptyGeometries,
        forceCoordTypeOfItemsOnGeometryCollection,
      ];
}
