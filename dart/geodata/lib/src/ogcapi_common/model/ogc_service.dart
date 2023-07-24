// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'ogc_conformance.dart';
import 'ogc_resource_meta.dart';

/// A service compliant with the OGC API Common standard.
abstract class OGCService {
  /// Get meta data (or "landing page" information) about this service.
  Future<OGCResourceMeta> meta();

  /// Conformance classes this service is conforming to.
  Future<OGCConformance> conformance();
}
