// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

/// A simple utility class to cache a single object for short periods.
@internal
class CachedObject<T> {
  final Duration _maxAge;

  T? _object;
  DateTime? _cachedTime;

  /// Create a cached object with [_maxAge] and empty state.
  CachedObject(this._maxAge);

  /// Get cached object of [T] synchronously, or when it's too old access a new
  /// one and return it.
  T get(T Function() accessor) {
    final obj = _getCached();
    if (obj != null) return obj;

    // got nothing from cache, need to access
    final newObj = accessor.call();
    _object = newObj;
    _cachedTime = DateTime.now();
    return newObj;
  }

  /// Get cached object of [T] asynchronously, or when it's too old access a new
  /// one and return it.
  Future<T> getAsync(Future<T> Function() accessor) async {
    final obj = _getCached();
    if (obj != null) return obj;

    // got nothing from cache, need to access
    final newObj = await accessor.call();
    _object = newObj;
    _cachedTime = DateTime.now();
    return newObj;
  }

  T? _getCached() {
    final obj = _object;
    final time = _cachedTime;
    if (obj != null && time != null) {
      if (DateTime.now().difference(time) > _maxAge) {
        // too old
        _object = null;
        _cachedTime = null;
      } else {
        //print('Cache hit ${obj.runtimeType}');

        // still valid
        return obj;
      }
    }

    // got nothing from cache
    return null;
  }
}
