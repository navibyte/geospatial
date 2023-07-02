#!/bin/bash
# upgrade all packages

cd geobase && echo "geobase" && dart pub upgrade
cd ../geocore && echo "geocore" && dart pub upgrade
cd ../geodata && echo "geodata" && dart pub upgrade
cd ../..