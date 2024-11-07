## 1.4.0

⚠️ NOTE: Version 1.4.0 currently under development (1.4.0-dev.0).

[geodata release 1.4.0](https://github.com/navibyte/geospatial/milestone/6)

🛠 Refactoring:
* [Change some external dependency version requirements to any - at least for http package #247](https://github.com/navibyte/geospatial/issues/247)

🛠 Maintenance:
* [Update very_good_analysis version to 6.0.0 #249](https://github.com/navibyte/geospatial/issues/249)

📚 Documentation updates:
* [Add retry support on http feature sources #166](https://github.com/navibyte/geospatial/issues/166)
* [Update docs to link latest "OGC API - Features - Part 3: Filtering" approved standard versions #252](https://github.com/navibyte/geospatial/issues/252)

## 1.2.1

Small documentation link fixes.

## 1.2.0

[geodata release 1.2.0](https://github.com/navibyte/geospatial/milestone/4)

✨ New (2024-05-26): The new documentation website ([geospatial.navibyte.dev](https://geospatial.navibyte.dev/)) for the [geodata](https://geospatial.navibyte.dev/v1/geodata/)
package documentation published along with the stable version 1.2.0.

🛠 Refactoring:
* [Shorten and streamline package readme docs #234](https://github.com/navibyte/geospatial/issues/234)

No functional changes on classes and functions, but major changes on
documentation with the publication of the new docs website.

## 1.1.0

[geodata release 1.1.0](https://github.com/navibyte/geospatial/milestone/1)

✨ New (2024-04-22):  The stable version 1.1.0 adds support for Newline-delimited GeoJSON. See the related [blog post](https://medium.com/@navibyte/decode-and-encode-geojson-wkt-and-wkb-in-dart-and-flutter-apps-ab2ef4ece2f1) about geobase changes.

🧩 Features:
* [Support for GeoJSON Text Sequences](https://github.com/navibyte/geospatial/issues/217)

🛠 Maintenance:
* Adding trailing commas to avoid "Missing a required trailing comma" message.

## 1.0.0

[geodata version 1.0.0 #187](https://github.com/navibyte/geospatial/issues/187)

✨ New (2023-10): The stable version 1.0.0 is now ready. See also the article [Geospatial tools for Dart - version 1.0 published](https://medium.com/@navibyte/geospatial-tools-for-dart-version-1-0-published-0f9673e510b3) at Medium.

🛠 Maintenance:
* Uses the latest `geobase` version 1.0.0

## 0.13.0

[geodata version 0.13.0 #198](https://github.com/navibyte/geospatial/issues/198)

🛠 Refactoring:
* [Simplify Feature and FeatureCollection types #195](https://github.com/navibyte/geospatial/issues/195)
* [Consistent crs and trs references in meta classes #196](https://github.com/navibyte/geospatial/issues/196)
* Smaller refactoring due to changes on `geobase` package, for example related to [Deprecate PositionArray, PositionCoords and BoxCoords #201](https://github.com/navibyte/geospatial/issues/201) and [Refactor SimpleGeometryContent #202](https://github.com/navibyte/geospatial/issues/202).

🛠 Maintenance:
* Uses the latest `geobase` version 0.6.0

## 0.12.1

Small document fixes (readme links to assets), no code changes.

## 0.12.0

[geodata version 0.12.0 #177](https://github.com/navibyte/geospatial/issues/177)

✨ New (2023-07): better client-side support for OGC API Features (Part 1 and 2).

⚠️ Breaking changes:
* [Check conformance classes known by OGC API Features #169](https://github.com/navibyte/geospatial/issues/169)
* Removed deprecated functions to create GeoJSON and OGC API Features clients.

🧩 Features:
* [Full client-side support for calling OGC API Features service according to Part 1 + 2 #9](https://github.com/navibyte/geospatial/issues/9)
* [Add support for API definition (like Open API 3.0) when accessing OGC API Features clients #170](https://github.com/navibyte/geospatial/issues/170)
* [Map HTTP status codes to feature service exception (OGC API Features) #68](https://github.com/navibyte/geospatial/issues/68)
* [Add initial support for OGC API - Features - Part 3: Filtering #180](https://github.com/navibyte/geospatial/issues/180)
* [Cache metadata object in OGC API Features clients for short periods #181](https://github.com/navibyte/geospatial/issues/181)
* [Alternative logics to resolve axis order #182](https://github.com/navibyte/geospatial/issues/182)

🛠 Maintenance:
* Uses the latest `geobase` version 0.5.0
* Removed extra internal export files and made internal imports more excplicit.
* A new library `package:geodata/formats.dart` with OpenAPI document and Common Query Language (CQL2) formats (partial support).

## 0.11.2 - 0.11.4

📚 Documentation updates:
* Readme enhanced with decision flowchart and better feature interface docs.

## 0.11.1

📚 Documentation updates:
* An introduction chapter for the readme.
* A new sample how to use OGC API Features for the readme and examples

🛠 Maintenance:
* The SDK constraint updated from '>=2.17.0 <3.0.0' to '>=2.17.0 <4.0.0'.

## 0.11.0

[geodata version 0.11.0 #162](https://github.com/navibyte/geospatial/issues/162)

🧩 Features:
* [Consistent factories for GeoJSON and OGC API Features clients #155](https://github.com/navibyte/geospatial/issues/155)

🛠 Maintenance:
* Uses the latest `geobase` version 0.4.0

## 0.10.1

📚 Small documentation updates. Also a link to the [Geospatial demos for Dart](https://github.com/navibyte/geospatial_demos) repository.

## 0.10.0

✨ New: Updated with latest [geobase](https://pub.dev/packages/geobase) version
0.3.0 based on [Dart](https://dart.dev/) SDK 2.17, and no longer with dependency
on [geocore](https://pub.dev/packages/geocore).

⚠️ Note this (using geobase instead of geocore) is a breaking change.

🧩 Features:
- [Decode GeoJSON and build data structures using new data structures by geobase #140](https://github.com/navibyte/geospatial/issues/140)

🛠 Refactoring:
- [Feature properties and data maps as Map<String, dynamic> instead of Map<String, Object?> #147](https://github.com/navibyte/geospatial/issues/147)
- [Refactor fromJson / toJson methods on model classes #150](https://github.com/navibyte/geospatial/issues/150)

🛠 Maintenance:
- [Lint rules without old strong mode, but with new "stricter type checks" #148](https://github.com/navibyte/geospatial/issues/148)
- - [Mark internal classes with @internal #149](https://github.com/navibyte/geospatial/issues/149)

## 0.9.0

✨ Updated with latest [geobase](https://pub.dev/packages/geobase) version
0.2.1 and [geocore](https://pub.dev/packages/geocore) version 0.9.0 based on
[Dart](https://dart.dev/) SDK 2.17.

🛠 Maintenance:
- [Upgrade to Dart 2.17 #105](https://github.com/navibyte/geospatial/issues/105)
- [Apply very_good_analysis 3.0.0+ lint rules #104](https://github.com/navibyte/geospatial/issues/104)
- [Library dependencies should not be too restrictive #111](https://github.com/navibyte/geospatial/issues/111)

## 0.8.1

Small fix with latest dependency to `geobase` version 0.1.1 and `geocore`
version 0.8.1.

## 0.8.0

Major and breaking changes compared to version 0.7.2.

After changes key features of this [geodata](https://pub.dev/packages/geodata)
package:
* Client-side data source abstraction for geospatial feature service Web APIs
* Implementations to read geospatial features
  * [GeoJSON](https://geojson.org/) features from Web APIs or files
  * [OGC API Features](https://ogcapi.ogc.org/features/) based services (partial support)

Depends on
* [geobase](https://pub.dev/packages/geobase)
* [geocore](https://pub.dev/packages/geocore)

⚠️ Breaking changes:
- [Refactor Feature class inheritance and types of id and properties members #39](https://github.com/navibyte/geospatial/issues/39)
- [Restructuring web api client for geospatial data #46](https://github.com/navibyte/geospatial/issues/46)
- [Use http package instead of datatools in API clients #65](https://github.com/navibyte/geospatial/issues/65)

📚 Documentation:
- [Update copyright clauses (years 2020-2022) and licenses #66](https://github.com/navibyte/geospatial/issues/66)

🛠 Maintenance:
- [Upgrade to Dart 2.15 #90](https://github.com/navibyte/geospatial/issues/90)

## 0.7.2

- [Apply very_good_analysis 2.4.0+ lint rules #36](https://github.com/navibyte/geospatial/issues/36)

## 0.7.1

- BETA version 0.7.1
- [Apply very_good_analysis 2.3.0+ lint rules #33](https://github.com/navibyte/geospatial/issues/33)

## 0.7.0

- BETA version 0.7.0 with breaking changes
- updated dependency 0.7.1 on [attributes](https://pub.dev/packages/attributes)
- [Official Dart lint rules applied with recommend set #32](https://github.com/navibyte/geospatial/issues/32)

## 0.6.0

- BETA version 0.6.0 with minor breaking changes
- [Lint rules and analysis options updated](https://github.com/navibyte/geospatial/issues/8)
- Also `implicit-casts` and `implicit-dynamic` to false requiring code changes
- many other smaller changes and optimizations partially due issues #8 

## 0.5.0

- BETA version 0.5.0 with stable null-safety requiring the stable Dart 2.12

## 0.5.0-nullsafety.0

- BETA version 0.5.0 with breaking changes compared to 0.4.1
- Quite extensive refactoring and partially fully rewritten
- [Resource metadata domain model in "geodata" package #18](https://github.com/navibyte/geospatial/issues/18)
- [Client-side support for calling reading GeoJSON web or file resource #10](https://github.com/navibyte/geospatial/issues/10)
- Mini-libraries provided by the package refactored:
  - api_common
    - Data source abstraction for client access of common geospatial Web APIs.
  - api_features
    - Data source abstraction for client access of geospatial features Web APIs.
  - geojson_features
    - A client-side data source to read GeoJSON features from a Web API or files.
  - oapi_common
    - Data source abstraction for client access of OGC API Common based services.
  - oapi_features
    - A client-side data source to read features from OGC API Features services.
- Code also restructured under lib/src
  - api
    - base
    - common
    - features
  - geojson
    - features
  - oapi
    - common
    - features
 
## 0.4.1-nullsafety.0

- Alpha version 0.4.1 with minor feature/private code changes compared to 0.4.0
- Updated dependency: `geocore` (^0.4.1-nullsafety.0) for geo data structures
- Small changes to adapt with changes by `geocore`

## 0.4.0-nullsafety.0

- Alpha version 0.4.0 with breaking changes compared to 0.3.0
- Updated dependency: `geocore` (^0.4.0-nullsafety.0) for geo data structures
- New dependency: `attributes` (^0.4.0-nullsafety.0) for common data structures
- New dependency: `datatools` (^0.4.0-nullsafety.0) for generic data clients
- Non-geospatial "client", "client_http" and "utils" libs moved to `datatools`
- Removed dependency: http (^0.12.2) as was needed by "client_http"
- Removed dependency: http_parser (^3.1.4) as was needed by "client_http"
- Restructured lib/src folder fully:
  - model
    - base
    - common
    - features
  - provider
    - common
    - features
  - source
    - oapi
      - common
      - features           
- Restructured mini-libraries provided by the package:
  - 'package:geodata/model_base.dart'
  - 'package:geodata/model_common.dart'
  - 'package:geodata/model_features.dart'
  - 'package:geodata/provider_common.dart'
  - 'package:geodata/provider_features.dart'
  - 'package:geodata/source_oapi_common.dart'
  - 'package:geodata/source_oapi_features.dart'
- Still the whole library is available by:
  - 'package:geodata/geodata.dart'
- Refactoring code in many places too

## 0.3.0-nullsafety.0

- Alpha version 0.3.0 with breaking changes compared to 0.2.0.
- Updated dependency: geocore (^0.3.0-nullsafety.0) for geo data structures
- Adaptation to the geocore changes: feature, collection and geometry classes
- Now uses GeoJSON parser from the geocore package
- Updated example code

## 0.2.0-nullsafety.0

- Alpha version 0.2.0 with breaking changes compared to 0.1.0.
- Now initial version to read items resource (features) from OGC API Features
- Provider abstraction refactored
- FeatureProvider has features() and featuresPaged() methdos (both async)
- Mechanism to handle paged responses from OGC API features items responses
- New code example: read_features.dart
- Updated dependency: geocore (^0.2.0-nullsafety.0) for geo data structures
- New dependency: synchronized (^3.0.0-nullsafety.1) for concurrency

## 0.1.0-nullsafety.0

- Initial pre-release version, the API of the library is not stable
- Designed for null-safety (requires sdk: '>=2.12.0-0 <3.0.0')
- Uses as dependency: equatable (^2.0.0-nullsafety.0)
- Uses as dependency: geocore (^0.1.0-nullsafety.0)
- Uses as dependency: http (^0.12.2)
- Uses as dependency: http_parser (^3.1.4)
- Web API client abstraction
- Web API client binding to HTTP using "http" package
- Initial parser and provider to read data from a OGC API Features service
  - Supported only reading "landing page", "conformance" and "collections"
  - Other functions to consume OGC API Features are NOT supported (yet)
