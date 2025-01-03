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

Copyright: (c) Chris Veness 2002-2024

Latitude/longitude spherical geodesy tools (see [latlong.html](https://www.movable-type.co.uk/scripts/latlong.html) and [geodesy-library.html#latlon-spherical](https://www.movable-type.co.uk/scripts/geodesy-library.html#latlon-spherical)), ellipsoidal geodesy tools (see [latlong-vincenty.html](https://www.movable-type.co.uk/scripts/latlong-vincenty.html)) and [UTM/MGRS tools](www.movable-type.co.uk/scripts/latlong-utm-mgrs.html):

Dart code file ported to this project | Related original JavaScript code
------------------------------------- | --------------------------------
[geodetic.dart](lib/src/geodesy/base/geodetic.dart) | [latlon-spherical.js](https://github.com/chrisveness/geodesy/blob/master/latlon-spherical.js)
[datum.dart](lib/src/geodesy/ellipsoidal/datum.dart) | [latlon-ellipsoidal-datum.js](https://github.com/chrisveness/geodesy/blob/master/latlon-ellipsoidal-datum.js)
[ellipsoidal.dart](lib/src/geodesy/ellipsoidal/ellipsoidal.dart) | [latlon-ellipsoidal.js](https://github.com/chrisveness/geodesy/blob/master/latlon-ellipsoidal.js)
[ellipsoidal_vincenty.dart](lib/src/geodesy/ellipsoidal/ellipsoidal_vincenty.dart) | [latlon-ellipsoidal-vincenty.js](https://github.com/chrisveness/geodesy/blob/master/latlon-ellipsoidal-vincenty.js)
[utm.dart](lib/src/geodesy/ellipsoidal/utm.dart) | [utm.js](https://github.com/chrisveness/geodesy/blob/master/utm.js)
[utm_mgrs.dart](lib/src/geodesy/ellipsoidal/utm_mgrs.dart) | [mgrs.js](https://github.com/chrisveness/geodesy/blob/master/mgrs.js)
[spherical_great_circle.dart](lib/src/geodesy/spherical/spherical_great_circle.dart) | [latlon-spherical.js](https://github.com/chrisveness/geodesy/blob/master/latlon-spherical.js)
[spherical_rhumb_line.dart](lib/src/geodesy/spherical/spherical_rhumb_line.dart) | [latlon-spherical.js](https://github.com/chrisveness/geodesy/blob/master/latlon-spherical.js)
[ellipsoidal_vincenty_test.dart](test/geodesy/ellipsoidal_vincenty_test.dart) | [latlon-ellipsoidal-vincenty-tests.js](https://github.com/chrisveness/geodesy/blob/master/test/latlon-ellipsoidal-vincenty-tests.js)
[spherical_ported_test.dart](test/geodesy/spherical_ported_test.dart) | [latlon-spherical-tests.js](https://github.com/chrisveness/geodesy/blob/master/test/latlon-spherical-tests.js)
[utm_ported_test.dart](test/geodesy/utm_ported_test.dart) | [utm-mgrs-tests.js](https://github.com/chrisveness/geodesy/blob/master/test/utm-mgrs-tests.js)

Geodesy representation conversion functions:

Dart code file ported to this project | Related original JavaScript code
------------------------------------- | --------------------------------
[dms.dart](lib/src/common/presentation/dms.dart) | [dms.js](https://github.com/chrisveness/geodesy/blob/master/dms.js)
[dms_ported_test.dart](test/coordinates/dms_ported_test.dart) | [dms-tests.js](https://github.com/chrisveness/geodesy/blob/master/test/dms-tests.js)

### Polylabel algorithm by Mapbox

Source: https://github.com/mapbox/polylabel

License: [ISC License](https://github.com/mapbox/polylabel/blob/master/LICENSE)

Copyright: Copyright (c) 2016 Mapbox

See also the
[blog post](https://blog.mapbox.com/a-new-algorithm-for-finding-a-visual-center-of-a-polygon-7c77e6492fbc)
(Aug 2016) by Vladimir Agafonkin introducing the `polylabel` algorithm.
 
Dart code file ported to this project | Related original JavaScript code
------------------------------------- | --------------------------------
[polylabel.dart](lib/src/geometric/cartesian/areal/polylabel.dart) | [polylabel.js](https://github.com/mapbox/polylabel/blob/master/polylabel.js)
[cartesian_areal_polylabel_test.dart](test/geometric/cartesian_areal_polylabel_test.dart) | [test.js](https://github.com/mapbox/polylabel/blob/master/test/test.js)

Also [JSON files](https://github.com/mapbox/polylabel/tree/master/test/fixtures)
from the source repository used by tests are ported.

### TinyQueue by Vladimir Agafonkin

Source: https://github.com/mourner/tinyqueue

License: [ISC License](https://github.com/mourner/tinyqueue/blob/main/LICENSE)

Copyright: Copyright (c) 2017, Vladimir Agafonkin

Dart code file ported to this project | Related original JavaScript code
------------------------------------- | --------------------------------
[tiny_queue.dart](lib/src/utils/tiny_queue.dart) | [index.js](https://github.com/mourner/tinyqueue/blob/main/index.js)
