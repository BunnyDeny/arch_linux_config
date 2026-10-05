#!/usr/bin/env bash
# 安装 neovim。依次执行：装包 → 把配置目录整个链到仓库。
#
# 注意：这里**只装 neovim 本体**，不碰 nvim 的插件。
# 那些插件（lazy.nvim、treesitter、各种 LSP 之类）由 lazy.nvim 自己在
# 第一次启动时按 lua/plugins/ 下的 spec 拉下来，而且 treesitter、mason
# 那些还会用到编译器、语言服务器之类的额外依赖 —— 那些不在本脚本职责里，
# 第一次开 nvim 让它自己装就行（需要联网）。
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${REPO_DIR}/install/lib.sh"

# 1. 本体
ensure_pkg neovim

# 2. 把 ~/.config/nvim 整个目录链到仓库的 nvim/
#
# 和 yazi 一样用整目录链接（而不是像 kitty/starship 那样一份份链文件）：
# 配置目录里文件太多（lua/ 下面一层层），而且 lazy.nvim 会往里面写
# lazy-lock.json，链成目录它才会跟着仓库走。
#
# 必须用 ensure_dir_symlink：ensure_symlink 是给文件写的，它靠 mv -Tf 原子换位，
# 而 mv -T 不允许拿软链接覆盖一个目录（rename(2) 会 EISDIR）。
ensure_dir_symlink "${REPO_DIR}/nvim" "${HOME}/.config/nvim"

echo "完成！第一次开 nvim 时 lazy.nvim 会自动把插件拉下来（需要联网）。"
