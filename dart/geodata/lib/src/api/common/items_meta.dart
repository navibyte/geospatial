// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

/// Metadata about a collection of items.
@immutable
class ItemsMeta with EquatableMixin {
  /// Create a meta instance.
  const ItemsMeta(
      {required this.timeStamp, this.numberMatched, this.numberReturned});

  /// The time stamp
  final DateTime timeStamp;

  /// An optional count of items matched.
  final int? numberMatched;

  /// An optional count of items returned.
  final int? numberReturned;

  @override
  List<Object?> get props => [timeStamp, numberMatched, numberReturned];
}
