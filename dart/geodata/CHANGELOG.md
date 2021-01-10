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
