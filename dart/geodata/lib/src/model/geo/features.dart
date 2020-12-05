// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import 'package:geocore/feature.dart';

import 'common.dart';

/// A feature collection with feature items and metadata.
@immutable
class FeatureItems<T extends Feature> with EquatableMixin {
  const FeatureItems({required this.all, required this.meta});

  final FeatureSeries<T> all;

  final ItemsMeta meta;

  @override
  List<Object?> get props => [all, meta];
}
