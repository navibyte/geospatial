// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Geospatial *aspects* for `geocore` that can be used independently too.
///
/// Contains following aspects or features:
/// * *schema*: an enum for `geometry` types
/// * *writer*: write objects with coordinate data to (text) formats
///
/// Usage: import `package:geocore/aspects.dart`
library aspects;

export 'src/aspects/schema.dart';
export 'src/aspects/writer.dart';
