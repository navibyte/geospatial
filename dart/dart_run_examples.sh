#!/bin/bash
# test all packages

cd geobase && echo "geobase" && dart example/geobase_example.dart && dart example/geobase_with_proj4d_example.dart
cd ../geocore && echo "geocore" && dart example/geocore_example.dart
cd ../geodata && echo "geodata" && dart example/geojson_example.dart && dart example/ogcapi_features_example.dart 
cd ../..
