#!/bin/bash
# test all packages

cd geobase && echo "geobase" && dart test
cd ../geocore && echo "geocore" && dart test
cd ../geodata && echo "geodata" && dart test
cd ../..