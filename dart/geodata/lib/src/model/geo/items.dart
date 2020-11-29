// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

/// A collection containing some set of items of the type [T].
abstract class Items<I extends Item, M extends ItemsMeta> {
  /// Returns an iterable allowing iterating [all] items of the type [T].
  Iterable<I> all();

  /// Meta data for the items contained.
  M meta();
}

/// An abstract base class for items.
abstract class Item {
  const Item();
}

/// Metadata about a collection of items.
@immutable
class ItemsMeta with EquatableMixin {
  const ItemsMeta({required this.timeStamp, this.numberReturned});

  /// The time stamp
  final DateTime timeStamp;

  /// An optional count of items returned.
  final int? numberReturned;

  @override
  List<Object?> get props => [timeStamp];
}
