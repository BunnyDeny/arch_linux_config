#!/usr/bin/env bash
# 安装 yazi（终端文件管理器）。依次执行：装包 → 配置目录整体链到仓库 → 装全部配色主题。
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${REPO_DIR}/install/lib.sh"

# 1. 本体
ensure_pkg yazi

# 2. 把 ~/.config/yazi 整个目录链到仓库的 yazi/
#
# 用整目录链接而不是一份份链文件，好处是下面第 3 步装出来的 flavor 会落到
# 仓库里的 yazi/flavors，ya pkg 生成的清单 yazi/package.toml 也在仓库里，
# 一起被 git 管起来 —— 换机器不用重装一遍。
#
# 这里必须用 ensure_dir_symlink 而不是 ensure_symlink —— 后者是给文件写的，
# 它靠 mv -Tf 一步换位，而 mv -T 不允许拿软链接覆盖一个目录（rename(2) 会 EISDIR）。
# 原因在 lib.sh 里也写了一行。
YAZI_TARGET="${REPO_DIR}/yazi"
YAZI_LINK="${HOME}/.config/yazi"

for conf in yazi.toml keymap.toml theme.toml; do
    if [[ ! -f "${YAZI_TARGET}/${conf}" ]]; then
        echo "[err ] 仓库缺少配置文件: ${YAZI_TARGET}/${conf}" >&2
        exit 1
    fi
done

ensure_dir_symlink "${YAZI_TARGET}" "${YAZI_LINK}"

# 3. 配色主题（flavor）—— 一次性全装上
#
# 这一步必须在第 2 步之后：ya pkg 把 flavor 装到 ~/.config/yazi/flavors/，
# 只有那个目录已经链进仓库，装出来的东西才归仓库管。
#
# 这里把清单上的**全部**装上，意义在于：装完之后切换主题就只是改
# theme.toml 里的 dark = "名字" 一行，不用再跑任何命令。
# 已经装过的会跳过，所以这个脚本可以反复跑。
#
# ID 有两种写法：
#   <owner>/<repo>            仓库本身就是一个 flavor
#   <owner>/<repo>:<名字>     一个仓库里放了多个 flavor
# 完整清单（含新增的）见 theme.toml 的注释，或 https://github.com/yazi-rs/flavors
FLAVOR_IDS=(
    yazi-rs/flavors:dracula
    yazi-rs/flavors:catppuccin-mocha
    yazi-rs/flavors:catppuccin-latte
    yazi-rs/flavors:catppuccin-frappe
    yazi-rs/flavors:catppuccin-macchiato
    CFY98/synthwave84
    BennyOe/tokyo-night
    Mintass/rose-pine
    Mintass/rose-pine-moon
    Mintass/rose-pine-dawn
    dangooddd/kanagawa
    marcosvnmelo/kanagawa-dragon
    muratoffalex/kanagawa-lotus
    melindachang/kanagawa-paper
    bennyyip/gruvbox-dark
    Sh00Fly/gruvbox-light
    matt-dong-123/gruvbox-material
    Chromium-3-Oxide/everforest-medium
    kmlupreti/ayu-dark
    AdithyanA2005/nord
    Malick-Tammal/monokai
    tomer-ben-david/neon
    6ruby1/eldritch
    identityapproved/lain
    azzamsa/modus
    matt-dong-123/base16
    rapidrabbit76/claude-inspired
    kshawkat/aurora-dawn
    kshawkat/aurora-storm
    cisco336/sequoia
    AdmiralBarbarossa/thinkpad-red-oled
    ficcdaf/ashen:ashen
    hankertrix/bluloco-yazi:bluloco-dark
    hankertrix/bluloco-yazi:bluloco-light
    ZimCodes/yazi-flavors:obsidian-glow
    gosxrgxx/flexoki-dark
    gosxrgxx/flexoki-light
)
# 故意没收进来的：Raideeen/dimidium —— 那个仓库里有 yazi 处理不了的东西
# （example/link-to-folder），装它会直接报错。

# 从 ID 推出 flavor 名字：带冒号的取冒号右边，不带的取最后一段路径。
# （装完以后目录名是 <名字>.yazi，theme.toml 里 dark 填的也是这个名字）
flavor_name() {
    local id="$1"
    if [[ "${id}" == *:* ]]; then
        echo "${id##*:}"
    else
        echo "${id##*/}"
    fi
}

pending=()
installed=0
for id in "${FLAVOR_IDS[@]}"; do
    name="$(flavor_name "${id}")"
    if [[ -d "${YAZI_TARGET}/flavors/${name}.yazi" ]]; then
        installed=$((installed + 1))
    else
        pending+=("${id}")
    fi
done

if [[ ${#pending[@]} -gt 0 ]]; then
    echo "[inst] 已有 ${installed} 个，还缺 ${#pending[@]} 个，开始装 ..."
    # 一个个装、坏掉的跳过 —— 不这样写的话，一个仓库有问题
    # （比如 dimidium 那种）就会让 set -e 把后面全掐掉。
    failed=()
    for id in "${pending[@]}"; do
        name="$(flavor_name "${id}")"
        if out="$(ya pkg add "${id}" 2>&1)"; then
            echo "[ok  ] ${name}"
        else
            failed+=("${id}")
            echo "[warn] ${name} 装不上，跳过（${id}）"
            printf '%s\n' "${out}" | tail -2 | sed 's/^/        /'
        fi
    done
    if [[ ${#failed[@]} -gt 0 ]]; then
        echo "[warn] 共 ${#failed[@]} 个装不上：${failed[*]}"
    fi
else
    echo "[skip] ${#FLAVOR_IDS[@]} 个主题都已在位"
fi

# 4. 删掉预览图
#
# 每个 flavor 目录里的 preview.png 只是 GitHub 页面上给人看的缩略图，
# yazi 运行时根本不用它，但它占了单个 flavor 体积的八成左右。
# 删掉之后 38 个主题合起来约 3M，不删是 28M。
# （哪天跑了 ya pkg upgrade 它们会回来，再跑一次本脚本即可。）
find "${YAZI_TARGET}/flavors" -name preview.png -delete 2>/dev/null || true

echo "完成！换主题：改 theme.toml 里的 dark = \"名字\"，然后重开 yazi。"
echo "      可选名字见 theme.toml 注释里的清单（共 ${#FLAVOR_IDS[@]} 个）。"
