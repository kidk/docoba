#!/usr/bin/env bash

# Build latest
pushd ../
docker build -t backup-test .
popd

# Run with bash for testing
docker run -it -v /var/run/docker.sock:/var/run/docker.sock -e DEBUG=true -v $PWD:/src backup-test bash
