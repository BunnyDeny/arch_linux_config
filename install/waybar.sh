#!/usr/bin/env bash
# 安装 waybar（Hyprland 状态栏，Tokyo-Night 风格）。依次执行：装包与字体依赖 → 建配置软链。
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${REPO_DIR}/install/lib.sh"

# 1. 本体与依赖字体（配置用到 Ubuntu Nerd / FontAwesome / 兜底字形）
ensure_pkg waybar
for pkg in ttf-ubuntu-nerd ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols otf-font-awesome ttf-roboto; do
    ensure_pkg "${pkg}"
done

# 2. 建配置软链（内容以仓库为准，缺失则报错）
for f in config.jsonc style.css power_menu.xml; do
    CONF_TARGET="${REPO_DIR}/waybar/${f}"
    CONF_LINK="${HOME}/.config/waybar/${f}"
    if [[ ! -f "${CONF_TARGET}" ]]; then
        echo "[err ] 仓库缺少配置文件: ${CONF_TARGET}" >&2
        exit 1
    fi
    ensure_symlink "${CONF_TARGET}" "${CONF_LINK}"
done

echo "完成！重启 waybar 生效：killall waybar && waybar &"
