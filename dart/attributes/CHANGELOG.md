## 0.5.0-nullsafety.0

- BETA version 0.5.0 without any breaking changes compared to 0.4.0

## 0.4.0-nullsafety.0

- Initial alpha version 0.4.0 (version starting with aligment to other packages)
- Designed for null-safety (requires sdk: '>=2.12.0-0 <3.0.0')
- Uses as dependency: `equatable` (^2.0.0-nullsafety.0)
- Uses as dependency: `meta` (^1.3.0-nullsafety.6)
- Uses as dependency: `intl` (^0.17.0-nullsafety.2)
- Some non-geospatial base code was moved here from `geocore`, then refactored
- Structure of lib/src folder:
  - collection
  - entity
  - values
- Mini-libraries provided by the package:
  - 'package:attributes/collection.dart'
  - 'package:attributes/entity.dart'
  - 'package:attributes/values.dart'
- The whole library is available by:
  - 'package:attributes/attributes.dart'
