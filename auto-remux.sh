#!/bin/bash

set -e

# === 检查并安装 mkvmerge ===
check_and_install_mkvtoolnix() {
  if ! command -v mkvmerge &> /dev/null; then
    echo "🔍 未检测到 mkvmerge，正在安装 mkvtoolnix..."
    if [ -f /etc/debian_version ]; then
      sudo apt update
      sudo apt install -y mkvtoolnix mkvtoolnix-gui
    else
      echo "❌ 当前系统暂不支持自动安装 mkvtoolnix，请手动安装。"
      exit 1
    fi
  fi
}

# === 主函数 ===
main() {
  check_and_install_mkvtoolnix

  echo "📁 请输入包含多个 BDMV 文件夹的【根目录路径】："
  read -rp "路径: " ROOT_DIR

  if [ ! -d "$ROOT_DIR" ]; then
    echo "❌ 目录不存在：$ROOT_DIR"
    exit 1
  fi

  echo "🔍 正在扫描 $ROOT_DIR 下的 BDMV 文件夹..."

  # 搜索所有包含 BDMV/STREAM 的文件夹
  mapfile -t BDMV_DIRS < <(find "$ROOT_DIR" -type d -path "*/BDMV/STREAM" -printf "%h\n" | sort)

  if [ "${#BDMV_DIRS[@]}" -eq 0 ]; then
    echo "❌ 未找到任何有效的 BDMV 文件夹。"
    exit 1
  fi

  echo "📂 发现以下 BDMV 文件夹："
  for i in "${!BDMV_DIRS[@]}"; do
    echo "$((i+1)). $(basename "${BDMV_DIRS[$i]}")"
  done

  echo "✳️ 请输入要 Remux 的编号（多个用空格，输入 0 表示全部）："
  read -rp "编号: " CHOICE

  if [ "$CHOICE" == "0" ]; then
    SELECTED_DIRS=("${BDMV_DIRS[@]}")
  else
    SELECTED_DIRS=()
    for n in $CHOICE; do
      index=$((n-1))
      if [ "$index" -ge 0 ] && [ "$index" -lt "${#BDMV_DIRS[@]}" ]; then
        SELECTED_DIRS+=("${BDMV_DIRS[$index]}")
      else
        echo "⚠️ 编号 $n 无效，跳过。"
      fi
    done
  fi

  echo "📤 请输入 MKV 文件的输出目录："
  read -rp "路径: " OUTPUT_DIR
  mkdir -p "$OUTPUT_DIR"

  for BDMV_PATH in "${SELECTED_DIRS[@]}"; do
    STREAM_DIR="$BDMV_PATH/BDMV/STREAM"
    MOVIE_NAME=$(basename "$BDMV_PATH")

    echo "🎬 正在处理：$MOVIE_NAME"

    MAIN_M2TS=$(find "$STREAM_DIR" -type f -name "*.m2ts" -printf "%s %p\n" | sort -nr | head -n1 | awk '{print $2}')

    if [ -z "$MAIN_M2TS" ]; then
      echo "❌ $MOVIE_NAME 未找到主影片 .m2ts 文件，跳过。"
      continue
    fi

    OUTPUT_PATH="$OUTPUT_DIR/${MOVIE_NAME}.mkv"
    echo "🔧 使用 mkvmerge Remux: $(basename "$MAIN_M2TS")"
    mkvmerge -o "$OUTPUT_PATH" "$MAIN_M2TS"

    echo "✅ 已输出：$OUTPUT_PATH"
  done

  echo "🎉 所有任务完成！"
}

main
