// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

/// Base meta with [title] and [description].
@immutable
class Meta with EquatableMixin {
  const Meta({required this.title, this.description});

  /// A required title for a meta element.
  final String title;

  /// An optional description for a meta element.
  final String? description;

  @override
  List<Object?> get props => [title, description];
}
