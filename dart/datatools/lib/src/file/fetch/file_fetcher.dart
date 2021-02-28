// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';

import 'dart:io' show File;

import 'package:path/path.dart' as p;

import '../../api/exceptions.dart';
import '../../api/fetch.dart';

import 'file_content.dart';

/// A basic file fetcher implementation (using 'dart:io', not working on web).
///
/// This fetcher requires that references used on fetch methods are relative
/// paths.
class FileFetcher extends Fetcher<FileContent> with FetchMixin<FileContent> {
  /// Create a file fetcher with base [path], normally refering to a directory.
  ///
  /// Optionally charset [encoding] or [contentType] can be set to specify those
  /// attributes of files accessed by this client.
  factory FileFetcher.basePath(String path,
      {Encoding encoding = utf8, String? contentType}) {
    return FileFetcher._(path, encoding, contentType);
  }

  FileFetcher._(this._basePath, this._encoding, this._contentType);

  final String _basePath;
  final Encoding _encoding;
  final String? _contentType;

  /// Ignore given [headers] on this version of the [FileFetcher].
  ///
  /// Returns `this` without mutations.
  @override
  FileFetcher headers(Map<String, String>? headers) => this;

  @override
  Future<FileContent> fetch(Uri reference) async {
    final file = await _fileFromUri(reference);
    try {
      return FileContent(
        reference,
        file,
        contentType: _contentType,
        encoding: _encoding,
        contentLength: await file.length(),
      );
    } catch (e) {
      throw ClientException.failed(reference, e);
    }
  }

  @override
  Future<FileContent> fetchStream(Uri reference) => fetch(reference);

  Future<File> _fileFromUri(Uri reference,
      [bool expectFileExists = true]) async {
    if (reference.hasAuthority || reference.isAbsolute) {
      throw ClientException.notRelative(reference);
    }
    final file = File(p.join(_basePath, reference.path));
    if (expectFileExists) {
      if (!(await file.exists())) {
        throw OriginException.of('File not existing',
            uri: reference, failure: OriginFailure.notFound);
      }
    }
    return file;
  }
}
