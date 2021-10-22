// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

// todo : range with spatial operations?

/// A range defining a set of items on a collection.
@immutable
class Range with EquatableMixin {
  /// A new range definition with [start] (>= 0) and optional positive [limit].
  const Range({required this.start, this.limit})
      : assert(start >= 0, 'Start index must be >= 0.'),
        assert(limit == null || limit >= 0, 'Limit must be null or >= 0.');

  /// The index to specify the first item (by index) of the range.
  final int start;

  /// An optional [limit] setting maximum number of items for the range.
  ///
  /// If null, then the range contains all items starting from [start].
  final int? limit;

  @override
  List<Object?> get props => [start, limit];
}
