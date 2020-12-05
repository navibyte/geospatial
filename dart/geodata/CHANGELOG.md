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
