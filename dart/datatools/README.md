# :cloud: Datatools

[![pub package](https://img.shields.io/pub/v/datatools.svg)](https://pub.dev/packages/datatools) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

**Datatools** is a library package for [Dart](https://dart.dev/) and 
[Flutter](https://flutter.dev/) mobile developers to help fetching data from
HTTP and file resources and other data sources.

Key features:
* Fetch API abstraction (content, control data, exceptions, fetch interface).
* Fetch API binding to HTTP and HTTPS resources (using [http](https://pub.dev/packages/http)).
* Fetch API binding to file resources (based on `dart:io`).
* Metadata structures to handle links.

**This package is at BETA stage, interfaces not fully final yet.** 

## :keyboard: Usage

Please, see more detailed examples on 
[sample code](example/datatools_example.dart).

Imports when using Fetch API for HTTP:

```dart
import 'package:datatools/fetch_http.dart';
```

Setting up a HTTP fetcher, fetching JSON, and also handling errors:

```dart
  // create a simple fetcher with an endpoint and headers
  final fetcher = HttpFetcher.simple(
          endpoints: [Uri.parse('https://jsonplaceholder.typicode.com/')])
      .headers({'user-agent': 'myapp'});

  // fetch by a relative path, get content as JSON and handle errors
  try {
    final json = await fetcher.fetchJson(Uri(path: 'posts/1'));
    // do something with JSON data...
  } on OriginException catch (e) {
    // handle exceptions ("not found" etc.) issued by origin server
  } catch (e) {
    // handle other exceptions, like caused client code 
  }
```

## :electric_plug: Installing

The package supports Dart [null-safety](https://dart.dev/null-safety) and 
using it requires the latest SDK from a beta channel. However your package using
it doesn't have to be migrated to null-safety yet.    

Please see the official 
[null-safety migration guide](https://dart.dev/null-safety/migration-guide)
how to switch to the latest beta release of Dart or Flutter SDKs.

In the `pubspec.yaml` of your project add the dependency:

```yaml
dependencies:
  datatools: ^0.5.0-nullsafety.0  
```

All dependencies used by `datatools` are also ready for 
[null-safety](https://dart.dev/null-safety)!

## :package: Package

This is a [Dart](https://dart.dev/) code package named `datatools` under the 
[geospatial](https://github.com/navibyte/geospatial) repository. 

The package is associated with (but not depending on) the
[geodata](https://pub.dev/packages/geodata) package. The `datatools` package 
contains non-geospatial tools to fetch data from HTTP and file resources. The
`geodata` package then provides client-side access for geospatial APIs and data
sources. 

## :card_file_box: Libraries

The package contains following mini-libraries:

Library         | Description 
----------------| -----------
**fetch_api**   | Fetch API abstraction (content, control data, exceptions, fetch interface).
**fetch_http**  | Fetch API binding to HTTP and HTTPS resources (using [http](https://pub.dev/packages/http)).
**fetch_file**  | Fetch API binding to file resources (based on `dart:io`).
**meta_link**   | Metadata structures to handle links.

The *fetch_file* mini library works on all platforms except web. Other libraries
should work on all Dart platforms.

For example to access a mini library you should use an import like:

```dart
import 'package:datatools/fetch_http.dart';
```

To use all (expect *fetch_file* that must be imported separately) libraries of the 
package:

```dart
import 'package:datatools/datatools.dart';
```

## :house_with_garden: Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## :copyright: License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).