# Attributes

[![pub package](https://img.shields.io/pub/v/attributes.svg)](https://pub.dev/packages/attributes) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

**Attributes** is a library package for [Dart](https://dart.dev/) and 
[Flutter](https://flutter.dev/) mobile developers to help on handling
values and property maps, identifiers and dynamic data objects or *Entities*.
It also contains utility functions to convert dynamic values to typed
null-safe primitive values. 

Key features:
* **ValueAccessor**: an interface to access typed values by key
* **ProperyMap**: a value accessor to data backed by `Map<String, dynamic>`
* **Identifier**: an identifier, represented as `String`, `int` or `BigInt`
* **Entity**: a dynamic data object with optional id and required properties

**This package is at BETA stage, interfaces not fully final yet.** 

## Usage

### Entities as dynamic data objects

Imports:

```dart
import 'package:attributes/entity.dart';
```

A simple example for creating a dynamic object with id and properties:
```dart
  // Create an entity with a String id and a property map (as a view backed
  // by a standard Map<String, dynamic> data).
  final obs = Entity.view(
    id: 'ROG',
    properties: {
      'title': 'Royal Observatory',
      'place': 'Greenwich',
      'city': 'London',
    },
  );

  // Get properties of the entity as PropertyMap.
  final props = obs.properties;

  // Type-safe and null-safe access to a property value by key.
  print(props.getString('title'));

  // Type-safe but nullable access to a property value that could be missing.
  print(props.tryString('missing') ?? 'prints if tryString returned null');
```

Please see [example code](example/atttributes_example.dart) for more detailed
sample.

### About identifiers, property maps and values

The *Entity* class introduced above has following class members: 
```dart
  /// An optional [id] for this entity.
  Identifier? get id;

  /// The required [properties] for this entity, allowed to be empty.
  PropertyMap get properties;
```

An entity object can be instantiated from strictly typed or dynamic data:
```dart
  /// A new entity of optional [id] and required [properties].
  factory Entity.of({Identifier? id, required PropertyMap properties}) =>
      EntityBase(
        id: id,
        properties: properties,
      );

  /// A new entity of optional [id] and required source [properties].
  ///
  /// This factory allows [id] to be null or an instance of [Identifier],
  /// `String`, `int` or `BigInt`. In other cases an ArgumentError is thrown.
  ///
  /// The [properties] is used as a source view for an entity. Any changes on 
  /// source reflect also on entity properties.
  factory Entity.view({dynamic id, required Map<String, dynamic> properties}) =>
      EntityBase(
        id: Identifier.idOrNull(id),
        properties: PropertyMap.view(properties),
      );
```

As described an identifier itself can be null or containing an actual id as 
`String`, `int` or `BigInt` value. Please see *Identifier* for more information.

*PropertyMap* implements *ValueAccessor* interface for type-safe property access
and can be instantiated using data backed by `Map<String, dynamic>`.

The *ValueAccessor* interface has following methods with `K` representing
a generic type for keys (ie. String when used by *PropertyMap*):

```dart
  // size and getting keys
  int get length;
  Iterable<K> get keys;

  // to get (dynamic) value by key, a value of any type can be null or non-null
  dynamic operator [](K key);

  // to check if a value by a key exists 
  bool exists(K key);

  // to check if a value by a key exists and that value is null
  bool hasNull(K key);

  // null-safe getters for value types
  String getString(K key);
  int getInt(K key, {int? min, int? max});
  BigInt getBigInt(K key, {BigInt? min, BigInt? max});
  double getDouble(K key, {double? min, double? max});
  bool getBool(K key);
  DateTime getTimeUTC(K key);

  // nullable getters for value types
  String? tryString(K key);
  int? tryInt(K key, {int? min, int? max});
  BigInt? tryBigInt(K key, {BigInt? min, BigInt? max});
  double? tryDouble(K key, {double? min, double? max});
  bool? tryBool(K key);
  DateTime? tryTimeUTC(K key);
```

### Geospatial data

Classes described above and provided by this package has no geospatial 
characteristics. 

However the associated [geocore](https://pub.dev/packages/geocore) package 
defines geometry and other geospatial data structures. For example there is a 
*Feature* class in the *geocore* package that extends *Entity* of the
*attributes* package allowing handling also geometry data in addition to generic
non-geospatial properties and identifiers.

## Installing

The package supports Dart [null-safety](https://dart.dev/null-safety) and 
using it requires at least
[Dart 2.12](https://medium.com/dartlang/announcing-dart-2-12-499a6e689c87)
from the stable channel. Please see the official 
[null-safety migration guide](https://dart.dev/null-safety/migration-guide).

In the `pubspec.yaml` of your project add the dependency:

```yaml
dependencies:
  attributes: ^0.5.0
```

All dependencies used by `attributes` are also ready for 
[null-safety](https://dart.dev/null-safety)!

## Package

This is a [Dart](https://dart.dev/) code package named `attributes` under the 
[geospatial](https://github.com/navibyte/geospatial) repository. 

The package is associated with (but not depending on) the
[geocore](https://pub.dev/packages/geocore) package. The `attributes` package 
contains non-geospatial data structures that are extended and utilized by the 
`geocore` package to provide geospatial data structures and utilities. 

## Libraries

The package contains following mini-libraries:

Library              | Description 
-------------------- | -----------
**collection**       | Value accessors and property maps.
**entity**           | Entity and Identifier data structures for handling dynamic data objects.
**values**           | Value conversions from dynamic objects to typed values. Also helper classes.

For example to access a mini library you should use an import like:

```dart
import 'package:attributes/entity.dart';
```

To use all libraries of the package:

```dart
import 'package:attributes/attributes.dart';
```

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).



