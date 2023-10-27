// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// NOTE: implement normalization for the template
//       `http://www.opengis.net/def/uom/{authority}/{version}/{code}`.

/// An abstract class for resolving temporal coordinate reference system
/// information.
///
/// A resolver can be accessed using [registry] that is initially instantiated
/// with the basic default implementation. It be customized by registering a
/// custom instance using [register]).
///
/// NOTE: The current version of this resolver class provides only the method
/// [normalizeId]. In future other methods might be added.
abstract class TemporalRefSysResolver {
  const TemporalRefSysResolver._();

  /// Normalizes the temporal coordinate reference system identifier.
  ///
  /// The normalization logic depends on the resolver of [registry].
  String normalizeId(String id);

  /// The current instance of [TemporalRefSysResolver], initially instantiated
  /// with the basic default implementation.
  ///
  /// Currently the basic default implemention returns identifiers unmodified.
  ///
  /// NOTE: In future the basic implementation is going to be extended to
  /// support also other identifier and more wide normalization logic.
  static TemporalRefSysResolver registry = const _BasicTemporalRefSysRegistry();

  /// Registers a custom instance of [TemporalRefSysResolver], available at
  /// static [registry] after calling this.
  // ignore: use_setters_to_change_properties
  static void register(TemporalRefSysResolver resolver) =>
      TemporalRefSysResolver.registry = resolver;
}

class _BasicTemporalRefSysRegistry implements TemporalRefSysResolver {
  const _BasicTemporalRefSysRegistry();

  @override
  String normalizeId(String id) {
    return id;
  }
}
