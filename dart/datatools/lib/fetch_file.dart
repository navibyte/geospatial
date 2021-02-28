// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Fetch API binding to file resources based on the `dart:io` package.
///
/// Please note that this library cannot be used on Dart or Flutter apps
/// targeted on a web browser as `dart:io` is not supported on web.
///
/// Usage: import `package:datatools/fetch_file.dart`
library fetch_file;

export 'fetch_api.dart';
export 'src/file/fetch.dart';
