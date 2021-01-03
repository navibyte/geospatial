// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import 'content.dart';
import 'endpoint.dart';
import 'locator.dart';

/// A function to locate a resource locator relative to the given [endpoint].
typedef Locate = Locator Function(Endpoint endpoint);

/// A function to locate a resource URL relative to the given [endpoint].
typedef LocateURL = String Function(Endpoint endpoint);

/// Maps a [LocateURL] function to a [Locate] function.
Locate locateByURL(LocateURL by) {
  return (endpoint) => Locator.url(by(endpoint));
}

/// A function to convert [content] to the type [T] (or null if not supported).
///
/// A null is returned when the converter does not support a conversion.
///
/// An exception is thrown if the conversion fails.
typedef Convert = T? Function<T>(Content content);

/// A base class for API queries.
///
/// Sub classes define API specific query parameters and logic to create URLs.
@immutable
abstract class Query with EquatableMixin {
  const Query();

  /// Creates a query with [locate] and optional [convert] functions.
  factory Query.of(Locate locate, [Convert? convert]) = QueryBase;

  /// Creates a query with [byURL] and optional [convert] functions.
  factory Query.url(LocateURL byURL, [Convert? convert]) = QueryBase.url;

  /// Resolves a locator for a resource relative to the given [endpoint].
  Locator locate(Endpoint endpoint);

  /// Converts [content] to the type [T] (or null if not supported).
  ///
  /// A null is returned when the converter does not support a conversion.
  ///
  /// An exception is thrown if the conversion fails.
  T? convert<T>(Content content) => null;

  @override
  List<Object?> get props => [];
}

/// A base implementation for the [Query].
class QueryBase extends Query {
  const QueryBase(this._locate, [this._convert]);

  QueryBase.url(LocateURL byURL, [this._convert])
      : _locate = locateByURL(byURL);

  final Locate _locate;
  final Convert? _convert;

  @override
  Locator locate(Endpoint endpoint) => _locate(endpoint);

  @override
  T? convert<T>(Content content) => _convert?.call(content);

  @override
  List<Object?> get props => [_locate, _convert];
}
