#!/usr/bin/env bash
# 安装 starship（shell 提示符工具）。依次执行：装包与字体依赖 → 建配置软链 → 启用提示符。
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${REPO_DIR}/install/lib.sh"

# 1. 本体与依赖字体
ensure_pkg starship
for pkg in ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols; do
    ensure_pkg "${pkg}"
done

# 2. 建配置软链（内容以仓库配置为准，缺失则报错）
CONF_TARGET="${REPO_DIR}/starship/starship.toml"
CONF_LINK="${HOME}/.config/starship.toml"
if [[ ! -f "${CONF_TARGET}" ]]; then
    echo "[err ] 仓库缺少配置文件: ${CONF_TARGET}" >&2
    exit 1
fi
ensure_symlink "${CONF_TARGET}" "${CONF_LINK}"

# 3. 启用 starship（bash 必加；fish 已装才加）
ensure_rc_line "${HOME}/.bashrc" 'eval "$(starship init bash)"'
if command -v fish >/dev/null 2>&1; then
    ensure_rc_line "${HOME}/.config/fish/config.fish" 'starship init fish | source'
else
    echo "[note] 未检测到 fish，跳过其启用"
fi

echo "完成！新开终端查看效果。"
