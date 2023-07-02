#!/bin/bash
# analyze all packages

cd geobase && echo "geobase" && dart analyze
cd ../geocore && echo "geocore" && dart analyze
cd ../geodata && echo "geodata" && dart analyze
cd ../..