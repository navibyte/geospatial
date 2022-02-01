// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'base_writer.dart';

/// A function that is capable of writing properties to [writer].
typedef WriteProperties = void Function(PropertyWriter writer);

/// An interface to write properties into some content format.
abstract class PropertyWriter extends BaseWriter {
  /// Writes a property map named by [name] and with contents in [map].
  /// 
  /// An example:
  /// ```dart
  ///   writer.properties('someProps', {
  ///             'foo': 100,
  ///             'bar': 'this is property value',
  ///             'baz': true,
  ///         });
  /// ```
  void properties(String name, Map<String, Object?> map);

  /// Writes a property named by [name] and with [value].
  ///
  /// An example:
  /// ```dart
  ///   writer..property('foo': 100)
  ///         ..property('bar': 'this is property value')
  ///         ..property('baz': true);
  /// ```
  void property(String name, Object? value);
}
