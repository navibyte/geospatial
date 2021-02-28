// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '../content.dart';
import '../control.dart';

import 'fetch_api.dart';

/// A fetcher with [FetchApi] for fetching and [Controlled] for control data.
abstract class Fetcher<C extends Content> extends FetchApi<C>
    implements Controlled<Fetcher<C>> {
  const Fetcher();
}
