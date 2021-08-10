// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import 'package:attributes/values.dart';

/// A filter defines a query for filtering items of some collection resource.
@immutable
class Filter with EquatableMixin {
  /// A new filter with optional [id] and optional positive [limit].
  const Filter({this.id, this.limit});

  /// An optional [id] to specify an item on a collection resource.
  ///
  /// An identifier can be represented either as `String`, `int` or `BigInt`,
  /// wrapped on an [Identifier] instance.
  final Identifier? id;

  /// An optional [limit] setting maximum number of items returned.
  ///
  /// If given, must be a positive integer.
  final int? limit;

  @override
  List<Object?> get props => [id, limit];
}
