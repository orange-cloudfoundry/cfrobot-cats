#!/usr/bin/env bash

includes=""

for include in "$@"
do
    includes="${includes} --include ${include}"
done

robot ${includes} --include runtime ./tests
