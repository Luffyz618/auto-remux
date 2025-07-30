#!/bin/bash

# 自动 Remux BDMV 为 MKV 脚本（适用于 Debian）
# GitHub: https://github.com/Luffyz618/auto-remux

check_mkvmerge() {
    if ! command -v mkvmerge &>/dev/null; then
        echo "🔍 mkvmerge 未安装，尝试安装 mkvtoolnix..."
        sudo apt update
        sudo apt install -y mkvtoolnix

        if ! command -v mkvmerge &>/dev/null; then
            echo "❌ mkvmerge 安装失败，请手动安装 mkvtoolnix 后再运行此脚本。"
            exit 1
        else
            echo "✅ mkvmerge 安装成功。"
        fi
    else
        echo "✅ 已检测到 mkvmerge。"
    fi
}

select_source_directory() {
    echo "📁 请输入存放 BDMV 文件夹的目录路径（绝对路径或相对路径）:"
    read -r SOURCE_DIR

    if [[ ! -d "$SOURCE_DIR" ]]; then
        echo "❌ 目录不存在，请检查路径。"
        exit 1
    fi

    echo "📂 发现以下 BDMV 文件夹："
    mapfile -t BDMV_DIRS < <(find "$SOURCE_DIR" -maxdepth 2 -type d -name "BDMV")
    if [ ${#BDMV_DIRS[@]} -eq 0 ]; then
        echo "❌ 未找到任何 BDMV 文件夹。"
        exit 1
    fi

    for i in "${!BDMV_DIRS[@]}"; do
        name=$(basename "$(dirname "${BDMV_DIRS[$i]}")")
        echo "$((i+1)). $name"
    done

    echo "👉 请输入要 remux 的编号（输入 0 表示全部）:"
    read -r CHOICE
}

select_output_directory() {
    echo "📤 请输入输出 MKV 文件的目录（不存在将自动创建）:"
    read -r OUTPUT_DIR
    mkdir -p "$OUTPUT_DIR"
}

remux_single_bdmv() {
    bdmv_path="$1"
    movie_name=$(basename "$(dirname "$bdmv_path")")
    stream_dir="$bdmv_path/STREAM"

    if [[ ! -d "$stream_dir" ]]; then
        echo "⚠️ 未找到 STREAM 文件夹，跳过 $movie_name"
        return
    fi

    # 选择最大的 m2ts 文件
    main_m2ts=$(find "$stream_dir" -type f -name "*.m2ts" -exec du -b {} + | sort -nr | head -n1 | cut -f2-)
    if [[ -z "$main_m2ts" ]]; then
        echo "⚠️ $movie_name 未找到 m2ts 文件，跳过"
        return
    fi

    output_file="$OUTPUT_DIR/${movie_name}.mkv"
    echo "🎬 Remuxing: $movie_name -> $output_file"

    mkvmerge -o "$output_file" "$main_m2ts"
    echo "✅ 已完成 $movie_name"
}

main() {
    check_mkvmerge
    select_source_directory
    select_output_directory

    if [[ "$CHOICE" == "0" ]]; then
        for dir in "${BDMV_DIRS[@]}"; do
            remux_single_bdmv "$dir"
        done
    else
        index=$((CHOICE - 1))
        remux_single_bdmv "${BDMV_DIRS[$index]}"
    fi

    echo "🏁 所有任务完成。"
}

main
