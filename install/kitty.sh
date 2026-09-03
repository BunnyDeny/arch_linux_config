#!/usr/bin/env bash
# 安装 kitty（终端模拟器，配置里指定 shell fish）。依次执行：装包 → 建配置软链。
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${REPO_DIR}/install/lib.sh"

# 1. 本体
ensure_pkg kitty

# 2. 建配置软链（内容以仓库为准，缺失则报错）
CONF_TARGET="${REPO_DIR}/kitty/kitty.conf"
CONF_LINK="${HOME}/.config/kitty/kitty.conf"
if [[ ! -f "${CONF_TARGET}" ]]; then
    echo "[err ] 仓库缺少配置文件: ${CONF_TARGET}" >&2
    exit 1
fi
ensure_symlink "${CONF_TARGET}" "${CONF_LINK}"

echo "完成！kitty 配置改动通常即时生效，未生效则重开一个 kitty 窗口。"
