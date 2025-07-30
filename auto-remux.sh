#!/bin/bash

set -e

# 检查 mkvmerge 是否安装
check_mkvmerge() {
    if ! command -v mkvmerge &>/dev/null; then
        echo "🛠️ 检测到未安装 mkvmerge，正在尝试安装..."
        if [[ -f /etc/debian_version ]]; then
            sudo apt update && sudo apt install -y mkvtoolnix
        elif [[ -f /etc/redhat-release ]]; then
            sudo dnf install -y mkvtoolnix
        else
            echo "❌ 不支持的 Linux 发行版，请手动安装 mkvtoolnix。" >&2
            exit 1
        fi

        # 安装后再次检查
        if ! command -v mkvmerge &>/dev/null; then
            echo "❌ mkvmerge 安装失败，请手动检查安装源或网络。" >&2
            exit 1
        else
            echo "✅ mkvmerge 安装成功。"
        fi
    else
        echo "✅ 已检测到 mkvmerge。"
    fi
}

# 获取 BDMV 主 m2ts 文件
get_main_m2ts() {
    local stream_dir="$1/BDMV/STREAM"
    find "$stream_dir" -type f -name "*.m2ts" -exec du -b {} + | sort -nr | head -n 1 | cut -f2
}

# 执行 remux 操作
remux_m2ts() {
    local input_dir="$1"
    local output_dir="$2"

    echo "📀 正在处理：$input_dir"

    main_m2ts=$(get_main_m2ts "$input_dir")
    if [[ -z "$main_m2ts" ]]; then
        echo "⚠️ 未找到 .m2ts 文件，跳过 $input_dir"
        return
    fi

    title=$(basename "$input_dir")
    output_file="$output_dir/${title}.mkv"

    echo "🎬 提取主影片：$main_m2ts"
    echo "📤 输出到：$output_file"

    mkvmerge -o "$output_file" "$main_m2ts"
    echo "✅ 完成：$output_file"
}

### 主流程开始 ###
check_mkvmerge

# 第一步：选择 BDMV 文件夹所在目录
read -rp "📁 请输入存放 BDMV 文件夹的主目录路径: " base_dir
[[ ! -d "$base_dir" ]] && echo "❌ 目录不存在。" && exit 1

# 第二步：列出所有包含 BDMV 的子目录
mapfile -t bdmv_dirs < <(find "$base_dir" -type d -name "BDMV" -exec dirname {} \;)
if [[ ${#bdmv_dirs[@]} -eq 0 ]]; then
    echo "❌ 未找到任何 BDMV 结构。"
    exit 1
fi

echo "🔍 检测到以下 BDMV 文件夹："
for i in "${!bdmv_dirs[@]}"; do
    echo "$((i + 1)). $(basename "${bdmv_dirs[$i]}")"
done

# 第三步：选择编号
read -rp "请输入要 remux 的编号（输入 0 表示全部）: " choice

# 第四步：选择输出目录
read -rp "📤 请输入输出 MKV 文件的目录路径: " output_dir
mkdir -p "$output_dir"

# 第五步：执行转换
if [[ "$choice" == "0" ]]; then
    for dir in "${bdmv_dirs[@]}"; do
        remux_m2ts "$dir" "$output_dir"
    done
else
    index=$((choice - 1))
    [[ -z "${bdmv_dirs[$index]}" ]] && echo "❌ 无效编号。" && exit 1
    remux_m2ts "${bdmv_dirs[$index]}" "$output_dir"
fi

echo "🎉 所有任务完成。"
