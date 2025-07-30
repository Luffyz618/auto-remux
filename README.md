# 🎬 auto-remux

一键将蓝光原盘（BDMV 格式）中的主影片 `.m2ts` 文件封装（remux）为 `.mkv`，支持自动识别主影片、批量处理、交互选择输出路径。

> ✅ 支持平台：Debian / Ubuntu VPS 或本地环境  
> 📦 依赖工具：`mkvtoolnix`（包含 `mkvmerge`）

零基础更详细的使用方法以及更多应用教程，请前往微信公众号：手把手教程 查看

<img src="assets/preview.jpg" alt="公众号" width="300">

---

## 🚀 快速开始

```
bash <(curl -fsSL https://raw.githubusercontent.com/Luffyz618/auto-remux/main/auto-remux.sh)
```

🔧 功能说明
自动检测是否已安装 mkvmerge，未安装则自动安装 mkvtoolnix

选择待处理的目录，自动扫描其中所有 BDMV 文件夹

按编号选择处理指定的 BDMV，或输入 0 一键处理全部

自动识别主影片（最大体积 .m2ts 文件）

Remux 成 .mkv 文件并输出到你指定的目录

📁 示例流程
选择蓝光原盘所在目录（自动列出所有 BDMV 文件夹）

选择一个编号进行 Remux，或输入 0 处理全部

选择输出 .mkv 文件的存放路径

自动识别主 .m2ts 文件并开始转换

完成后会显示每个文件的输出路径

🧱 依赖项
本脚本依赖 mkvmerge 工具（来自 mkvtoolnix 套件）：

脚本将自动安装：

Debian/Ubuntu 系统使用 apt 安装官方源中的 mkvtoolnix

📂 示例结构
```
📁 /mnt/blu-rays/
   ├── Movie_A/
   │   └── BDMV/
   ├── Movie_B/
   │   └── BDMV/
输出后：
```

```
📁 /mnt/output/
   ├── Movie_A.mkv
   ├── Movie_B.mkv
```
💬 注意事项

只能处理单独.m2ts 文件原盘，多个.m2ts拼接的原盘不支持


📜 License
MIT License
