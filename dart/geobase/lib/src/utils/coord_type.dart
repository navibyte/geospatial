// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/vector_data/model/bounded/bounded.dart';

/// Resolves the coordinate type for [item] and/or [collection].
///
/// The returned type is such that it's valid for all items. For example if
/// a collection has items with types `Coords.xy`, `Coords.xyz` and
/// `Coords.xym`, then `Coords.xy` is returned. When all items are `Coords.xyz`,
/// then `Coords.xyz` is returned.
@internal
Coords resolveCoordTypeFrom<E extends Bounded>({
  E? item,
  Iterable<E>? collection,
}) {
  var is3D = true;
  var isMeasured = true;

  if (item != null) {
    final type = item.coordType;
    is3D &= type.is3D;
    isMeasured &= type.isMeasured;
  }

  if (collection != null) {
    for (final elem in collection) {
      final type = elem.coordType;
      is3D &= type.is3D;
      isMeasured &= type.isMeasured;
      if (!is3D && !isMeasured) break;
    }
  }

  return Coords.select(is3D: is3D, isMeasured: isMeasured);
}
