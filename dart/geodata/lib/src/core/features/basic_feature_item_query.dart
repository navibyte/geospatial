// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '/src/core/data.dart';

/// A query for requesting a feature from a basic feature source.
@immutable
class BasicFeatureItemQuery with GeodataQuery, EquatableMixin {
  /// Create a new feature item query with the required [id].
  const BasicFeatureItemQuery({
    required this.id,
    this.crs,
    this.extraParams,
  });

  /// An identifier specifying an item on a feature source.
  ///
  /// Note that an identifier could be textual or a number but reprensented here
  /// as a String object.
  final String id;

  @override
  final String? crs;

  @override
  final Map<String, String>? extraParams;

  @override
  List<Object?> get props => [id, crs, extraParams];
}
