// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A function to write properties to [output].
typedef WriteProperties = void Function(PropertyContent output);

/// An interface to write properties to format encoders and object builders.
mixin PropertyContent {
  /// Writes a property map named by [name] and with contents in [map].
  ///
  /// An example:
  /// ```dart
  ///  content.properties('someProps', {
  ///             'foo': 100,
  ///             'bar': 'this is property value',
  ///             'baz': true,
  ///         });
  /// ```
  void properties(String name, Map<String, dynamic> map);

  /// Writes a property named by [name] and with [value].
  ///
  /// An example:
  /// ```dart
  ///   content..property('foo', 100)
  ///          ..property('bar', 'this is property value')
  ///          ..property('baz', true);
  /// ```
  void property(String name, Object? value);
}
