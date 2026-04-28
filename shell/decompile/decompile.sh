#!/bin/bash

CFR_JAR="cfr-0.152.jar"   # 改成你的路径

find . -type f -name "*.class" | while read classfile; do
    # 去掉开头 ./，取最外层目录
    path="${classfile#./}"
    topdir="${path%%/*}"

    # 如果就在当前目录（没有子目录）
    if [[ "$path" != */* ]]; then
        outdir="./-java"
    else
        outdir="./${topdir}-java"
    fi

    mkdir -p "$outdir"

    java -jar "$CFR_JAR" "$classfile" --outputdir "$outdir"
done