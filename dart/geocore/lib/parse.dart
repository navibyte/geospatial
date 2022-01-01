// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// GeoJSON and WKT (Well-known text representation of geometry) data parsers.
///
/// This library exports also all classes of `package:geocore/base.dart`,
/// `package:geocore/common.dart`, `package:geocore/coordinates.dart` and
/// `package:geocore/data.dart`.
/// 
/// Usage: import `package:geocore/parse.dart`
library parse;

export 'base.dart';
export 'common.dart';
export 'coordinates.dart';
export 'data.dart';

export 'src/parse/factory.dart';
export 'src/parse/geojson.dart';
export 'src/parse/wkt.dart';
