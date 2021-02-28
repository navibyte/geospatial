// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Fetch API abstraction with binding to HTTP and HTTPS resources.
///
/// Usage: import `package:datatools/datatools.dart`
///
/// Exports following mini-libraries at once:
/// - `package:datatools/fetch_api.dart`
/// - `package:datatools/fetch_http.dart`
/// - `package:datatools/meta_link.dart`
///
/// However does NOT export the following (that must be imported explicitely):
/// - `package:datatools/fetch_file.dart`
library datatools;

// Export mini-libraries forming the whole "datatools" library.
export 'fetch_api.dart';
export 'fetch_http.dart';
export 'meta_link.dart';
