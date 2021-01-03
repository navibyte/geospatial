// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

import 'package:datatools/datatools.dart';

/*
To test run this from command line: 

dart example/datatools_example.dart
*/

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  // call simple demos
  _metadataStructures();
}

void _metadataStructures() {
  print('');
  print('Create some basic metadata structures.');

  // Link
  print(Link(
    href: 'http://example.com',
    rel: 'alternate',
    type: 'application/json',
    title: 'Other content',
  ));

  // todo : more examples ....
}
