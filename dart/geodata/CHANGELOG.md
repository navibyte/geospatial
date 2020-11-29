## 0.1.0-nullsafety.0

- Initial pre-release version, the API of the library is not stable
- Designed for null-safety (requires sdk: '>=2.12.0-0 <3.0.0')
- Uses as dependency: equatable (^2.0.0-nullsafety.0)
- Uses as dependency: geocore (0.1.0-nullsafety.0)
- Uses as dependency: http (^0.12.2)
- Uses as dependency: http_parser (^3.1.4)
- Web API client abstraction
- Web API client binding to HTTP using "http" package
- Initial parser and provider to read data from a OGC API Features service
  - Supported only reading "landing page", "conformance" and "collections"
  - Other functions to consume OGC API Features are NOT supported (yet)
