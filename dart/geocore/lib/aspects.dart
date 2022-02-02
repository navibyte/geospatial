// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Geospatial *aspects* for `geocore` that can be used independently too.
///
/// Contains following aspects or features:
/// * *codes*: enums for coordinate and geometry types
/// * *data*: basic interfaces for (geospatial) positions and coordinates
/// * *encode*: write objects with coordinate data to (text) formats
/// * *format*: some base formats including support for GeoJSON and WKT
///
/// Usage: import `package:geocore/aspects.dart`
library aspects;

export 'src/aspects/codes.dart';
export 'src/aspects/data.dart';
export 'src/aspects/encode.dart';
export 'src/aspects/format.dart';
