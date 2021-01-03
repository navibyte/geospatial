// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: omit_local_variable_types

import 'package:equatable/equatable.dart';

import 'package:attributes/attributes.dart';

/*
To test run this from command line: 

dart example/attributes_example.dart
*/

void main() {
  // configure Equatable to apply toString() default impls
  EquatableConfig.stringify = true;

  // call simple demos
  _identifiers();
  _entities();
}

void _identifiers() {
  print('');
  print('Create some identifiers.');

  // Create id from String
  print(Identifier.fromString('some-id'));

  // Create id from int
  print(Identifier.fromInt(123));

  // Create id from BigInt
  print(Identifier.fromBigInt(BigInt.one));

  // Create id from an Object that is allowed to be String, int or BigInt
  Object obj = 123;
  final id = Identifier.from(obj);
  print(id);

  // Access id value as int
  int nullSafe = id.asInt();
  int? nullable = id.tryAsInt();
  int nullableWithDefault = id.tryAsInt() ?? 0;
  print('$nullSafe $nullable $nullableWithDefault');
}

void _entities() {
  print('');
  print('Create some dynamic data objects or entities.');

  // An observatory "entity" with id and properties
  final obs = Entity.view(
    id: 'ROG',
    properties: {
      'title': 'Royal Observatory',
      'place': 'Greenwich',
      'city': 'London',
      'isMuseum': true,
      'code': '000',
      'founded': 1675,
      'prime': DateTime.utc(1884, 10, 22),
      'measure': 5.79,
      'meta': null,
      'extra': {
        'nearby': 'River Thames',
      }
    },
  );
  print(obs);

  // Nullable identifier of the entity.
  Identifier? id = obs.id;
  print('Id: $id');

  // Get properties of the entity.
  PropertyMap props = obs.properties;

  // Loop all property keys.
  print('Keys:');
  props.keys.forEach((key) => print('    $key'));

  // Loop through properties (key-value pairs).
  print('Properties:');
  props.map.forEach((key, value) => print('    $key: $value'));

  // Null-safe access to property values by key expecting specific types.
  // All such methods: getString, getInt, getBigInt, getDouble, getBool, getTime
  String title = props.getString('title');
  int year = props.getInt('founded');
  print('Getters (type-safe non-null):');
  print('    getString: $title');
  print('    getInt: $year');

  // If unsure whether an value referenced by key exists, there is also another
  // set of getters that try to access (and convert as needed) specific nullable
  // type. These methods return null if a value was not accessible.
  // All such methods: tryString, tryInt, tryBigInt, tryDouble, tryBool, tryTime
  double? measureDouble = props.tryDouble('measure');
  int? missingInt = props.tryInt('missing');
  int missingIntWithDefault = props.tryInt('missing') ?? 10;
  print('Getters (type-safe nullable):');
  print('    tryDouble: $measureDouble'); // should be 5.79
  print('    tryInt: $missingInt'); // should be null
  print('    tryInt with default: $missingIntWithDefault'); // should be 10

  // Numeric values can be clamped to a range.
  double? clampedDouble = props.tryDouble('measure', min: 5.5, max: 5.6);
  print('    tryDouble clamped: $clampedDouble'); // should be 5.6

  // Check whether a property exists but has a null value.
  bool existsAndHasNull = props.hasNull('meta');
  bool existsAndHasNotNull = props.hasNull('code');
  bool exists = props.exists('meta');
  bool notExists = props.exists('missing');
  print('Whether exists and/or is null:');
  print('    hasNull: $existsAndHasNull'); // should be true
  print('    hasNull: $existsAndHasNotNull'); // should be false
  print('    exists: $exists'); // should be true
  print('    exists: $notExists'); // should be false

  // Property values, also non-primitive, can be accessed with [] operator too.
  // Returned value is dynamic, so some null-safety and type-safety checking
  // maybe needed.
  final extra = props['extra'];
  if (extra != null && extra is Map<String, dynamic>) {
    print('Accessing data from sub property map:');
    final extraValues = PropertyMap.view(extra);
    String nearby = extraValues.tryString('nearby') ?? 'nothing-near';
    print('    tryString: $nearby');
  }
}
