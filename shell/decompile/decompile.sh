#!/bin/bash
# 批量反编译脚本 - 直接传 jar 给 CFR
# 输出目录为 jar 文件名（去掉 .jar）加 -java 后缀

CFR_JAR="$(pwd)/cfr-0.152.jar"
PARALLEL_JOBS=$(nproc 2>/dev/null || echo 4)

if [ ! -f "$CFR_JAR" ]; then
    echo "❌ 找不到 cfr-0.152.jar，请确保它在当前目录下"
    exit 1
fi

echo "🔍 扫描当前目录: $(pwd)"
echo "⚙️  并行线程数: $PARALLEL_JOBS"
echo ""

# 收集所有 jar（排除 cfr 本身）
jars=()
for jar in *.jar; do
    [[ "$jar" == cfr-*.jar ]] && continue
    jars+=("$jar")
done

if [ ${#jars[@]} -eq 0 ]; then
    echo "⚠️  当前目录下没有找到 .jar 文件"
    exit 0
fi

echo "📦 找到 ${#jars[@]} 个 jar 待处理:"
for j in "${jars[@]}"; do
    out="${j%.jar}-java"
    echo "   - $j  →  $out"
done
echo ""

decompile_jar() {
    local jar_file="$1"
    local cfr_jar="$2"
    local base_dir="$3"
    local out_dir="${base_dir}/${jar_file%.jar}-java"

    mkdir -p "$out_dir"
    echo "▶ 开始: $jar_file"

    java -jar "$cfr_jar" \
        --outputdir "$out_dir" \
        --silent true \
        --comments false \
        --clobber true \
        "${base_dir}/${jar_file}" \
        2>"${out_dir}/_cfr_errors.log"

    local java_count
    java_count=$(find "$out_dir" -name "*.java" 2>/dev/null | wc -l | tr -d ' ')
    [ ! -s "${out_dir}/_cfr_errors.log" ] && rm -f "${out_dir}/_cfr_errors.log"

    if [ "$java_count" -gt 0 ]; then
        echo "✅ 完成: $jar_file → ${jar_file%.jar}-java ($java_count 个 .java)"
    else
        echo "❌ 失败: $jar_file (见 ${jar_file%.jar}-java/_cfr_errors.log)"
    fi
}

export -f decompile_jar

BASE_DIR="$(pwd)"
start_time=$(date +%s)

running=0
for jar in "${jars[@]}"; do
    decompile_jar "$jar" "$CFR_JAR" "$BASE_DIR" &
    ((running++))
    if [ "$running" -ge "$PARALLEL_JOBS" ]; then
        wait -n 2>/dev/null || wait
        ((running--))
    fi
done
wait

end_time=$(date +%s)
elapsed=$((end_time - start_time))

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 全部完成！耗时 ${elapsed} 秒"
echo ""
total_java=0
for jar in "${jars[@]}"; do
    out_dir="${jar%.jar}-java"
    if [ -d "$out_dir" ]; then
        java_count=$(find "$out_dir" -name "*.java" 2>/dev/null | wc -l | tr -d ' ')
        total_java=$((total_java + java_count))
        printf "   %-40s %s 个 .java\n" "$out_dir" "$java_count"
    fi
done
echo ""
echo "   合计: $total_java 个 .java 文件"