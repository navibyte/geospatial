#!/bin/bash
# format all packages

cd geobase && echo "geobase" && dart format lib example test
cd ../geocore && echo "geocore" && dart format lib example test
cd ../geodata && echo "geodata" && dart format lib example test
cd ..
