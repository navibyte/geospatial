# Derivative work for the geobase package

## Authors

This project is authored by [Navibyte](https://navibyte.com).

More information and other links are available at the
[geospatial](https://github.com/navibyte/geospatial) repository from GitHub. 

## License

This project is licensed under the "BSD-3-Clause"-style license.

Please see the 
[LICENSE](https://github.com/navibyte/geospatial/blob/main/LICENSE).

## Derivative work

This project contains derivative work originated from following sources.

### Geodesy functions by Chris Veness

Source: https://github.com/chrisveness/geodesy

License: [MIT License](https://github.com/chrisveness/geodesy/blob/master/LICENSE)

Copyright: (c) Chris Veness 2002-2022

Latitude/longitude spherical geodesy tools (see [latlong.html](www.movable-type.co.uk/scripts/latlong.html) and [geodesy-library.html#latlon-spherical](www.movable-type.co.uk/scripts/geodesy-library.html#latlon-spherical)):

Dart code file ported to this project | Related original JavaScript code
------------------------------------- | --------------------------------
[geodetic.dart](lib/src/geodesy/base/geodetic.dart) | [latlon-spherical.js](https://github.com/chrisveness/geodesy/blob/master/latlon-spherical.js)
[spherical_great_circle.dart](lib/src/geodesy/spherical/spherical_great_circle.dart) | [latlon-spherical.js](https://github.com/chrisveness/geodesy/blob/master/latlon-spherical.js)
[spherical_rhumb_lone.dart](lib/src/geodesy/spherical/spherical_rhumb_lone.dart) | [latlon-spherical.js](https://github.com/chrisveness/geodesy/blob/master/latlon-spherical.js)

Geodesy representation conversion functions:

Dart code file ported to this project | Related original JavaScript code
------------------------------------- | --------------------------------
[dms.dart](lib/src/coordinates/geographic/dms.dart) | [dms.js](https://github.com/chrisveness/geodesy/blob/master/dms.js)
[dms_ported_test.dart](test/coordinates/dms_ported_test.dart) | [dms-tests.js](https://github.com/chrisveness/geodesy/blob/master/test/dms-tests.js)