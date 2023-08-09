// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/codes/coords.dart';
import '/src/vector_data/model/bounded/bounded.dart';

/// Resolves the coordinate type for [item] and/or [collection].
@internal
Coords resolveCoordTypeFrom<E extends Bounded>({
  E? item,
  Iterable<E>? collection,
}) {
  var is3D = false;
  var isMeasured = false;

  if (item != null) {
    final type = item.resolveCoordType();
    is3D |= type.is3D;
    isMeasured |= type.isMeasured;
  }

  if (collection != null) {
    for (final elem in collection) {
      final type = elem.resolveCoordType();
      is3D |= type.is3D;
      isMeasured |= type.isMeasured;
      if (is3D && isMeasured) break;
    }
  }

  return Coords.select(is3D: is3D, isMeasured: isMeasured);
}
