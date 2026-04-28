#!/bin/bash

for jar in *.jar; do
    dir="${jar%.jar}"
    mkdir -p "$dir"
    unzip -q "$jar" -d "$dir"
done