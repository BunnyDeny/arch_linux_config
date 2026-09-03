#!/usr/bin/env bash
# 全局配置：.bashrc、fish 配置、hyprland、git 配置。依次执行：装依赖 → 链接四个配置。
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${REPO_DIR}/install/lib.sh"

# 1. 依赖（两份配置分别需要 fish 与 hyprland 才生效）
for pkg in fish hyprland; do
    ensure_pkg "${pkg}"
done

# link_conf <仓库内相对路径> <目标绝对路径>
link_conf() {
    local src="${REPO_DIR}/$1" dest="$2"
    if [[ ! -f "${src}" ]]; then
        echo "[err ] 仓库缺少配置文件: ${src}" >&2
        exit 1
    fi
    ensure_symlink "${src}" "${dest}"
}

# 2. bash
link_conf "bash/.bashrc"        "${HOME}/.bashrc"

# 3. fish
link_conf "fish/config.fish"    "${HOME}/.config/fish/config.fish"

# 4. hypr
link_conf "hypr/hyprland.lua"   "${HOME}/.config/hypr/hyprland.lua"

# 5. git
link_conf "git/.gitconfig"      "${HOME}/.gitconfig"

echo "完成！新开 shell 生效；hyprland 配置改动后 hyprctl reload。"
