#!/bin/bash
# downgrade all packages

cd geobase && echo "geobase" && dart pub downgrade
cd ../geocore && echo "geocore" && dart pub downgrade
cd ../geodata && echo "geodata" && dart pub downgrade
cd ../..