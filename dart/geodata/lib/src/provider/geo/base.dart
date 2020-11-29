// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import '../../model/geo/common.dart';
import '../../model/geo/items.dart';

abstract class Provider<C extends Items, M extends ProviderMeta> {
  Future<M> meta();

  Future<C> items();
}
