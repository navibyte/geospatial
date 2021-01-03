// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

/// A locator refers to some resource.
abstract class Locator {
  const Locator();

  /// Creates a locator from a simple URL.
  factory Locator.url(String url) = LocatorBase;

  /// An URL for the resource this locator is referring to.
  String get url;

  // todo - other properties needed for accessing a resource, like auth, headers
}

/// A base implementation for the [Locator].
@immutable
class LocatorBase extends Locator with EquatableMixin {
  const LocatorBase(this.url);

  @override
  final String url;

  @override
  List<Object?> get props => [url];
}
