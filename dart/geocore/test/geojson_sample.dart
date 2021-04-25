// -----------------------------------------------------------------------------
// Test data sources:
//   https://geojson.org/
//   https://tools.ietf.org/html/rfc7946

/// GeoJSON sample feature from: https://geojson.org/
const geojsonFeature = '''
{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [125.6, 10.1]
  },
  "properties": {
    "name": "Dinagat Islands"
  }
}''';

/// GeoJSON sample feature collection from: https://tools.ietf.org/html/rfc7946
const geojsonFeatureCollection = '''
{
       "type": "FeatureCollection",
       "features": [{
           "type": "Feature",
           "geometry": {
               "type": "Point",
               "coordinates": [102.0, 0.5]
           },
           "properties": {
               "prop0": "value0"
           }
       }, {
           "type": "Feature",
           "geometry": {
               "type": "LineString",
               "coordinates": [
                   [102.0, 0.0],
                   [103.0, 1.0],
                   [104.0, 0.0],
                   [105.0, 1.0]
               ]
           },
           "properties": {
             "prop0": "value0",
               "prop1": 0.0
           }
       }, {
           "type": "Feature",
           "geometry": {
               "type": "Polygon",
               "coordinates": [
                   [
                       [100.0, 0.0],
                       [101.0, 0.0],
                       [101.0, 1.0],
                       [100.0, 1.0],
                       [100.0, 0.0]
                   ]
               ]
           },
           "properties": {
               "prop0": "value0",
               "prop1": {
                   "this": "that"
               }
           }
       }]
   }''';

/// GeoJSON sample feature with bbox from: https://tools.ietf.org/html/rfc7946
const geojsonBboxFeature = '''
{
       "type": "Feature",
       "bbox": [-10.0, -10.0, 10.0, 10.0],
       "geometry": {
           "type": "Polygon",
           "coordinates": [
               [
                   [-10.0, -10.0],
                   [10.0, -10.0],
                   [10.0, 10.0],
                   [-10.0, -10.0]
               ]
           ]
       }
   }''';

/// GeoJSON sample feature with bbox from: https://tools.ietf.org/html/rfc7946
const geojsonBboxFeatureCollection = '''
{
       "type": "FeatureCollection",
       "bbox": [100.0, 0.0, -100.0, 105.0, 1.0, 0.0],
       "features": [
       ]
   }''';

/// GeoJSON sample feature with extended elements from: https://tools.ietf.org/html/rfc7946
const geojsonExtendedFeature = '''
{
       "type": "Feature",
       "id": "f2",
       "geometry": {
           "type": "Polygon",
           "coordinates": [
               [
                   [-10.0, -10.0],
                   [10.0, -10.0],
                   [10.0, 10.0],
                   [-10.0, -10.0]
               ]
           ]
       },
       "properties": {},
       "centerline": {
           "type": "LineString",
           "coordinates": [
               [-170, 10],
               [170, 11]
           ]
       }
   }''';
