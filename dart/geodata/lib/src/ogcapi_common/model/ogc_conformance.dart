// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A wrapper for conformance classes for a OGC API Common compliant service.
///
/// See [OGC API Common](https://github.com/opengeospatial/ogcapi-common).
@immutable
class OGCConformance extends Equatable {
  /// Conformance classes a service is conforming to.
  final Iterable<String> classes;

  /// Creates a wrapper for conformance classes a service is conforming to.
  const OGCConformance(this.classes);

  @override
  List<Object?> get props => [classes];
}
