#!/usr/bin/env bash

# Build latest
pushd ../
docker build -t backup-test .
popd

# Run with bash for testing
docker run -it -v "$PWD/../types/:/types/" -v /var/run/docker.sock:/var/run/docker.sock -v /:/host/:ro -e DEBUG=true -v $PWD:/src backup-test bash
