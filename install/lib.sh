#!/usr/bin/env bash
# lib.sh：install/*.sh 的共享函数，先 source 再调用。
set -euo pipefail

# ensure_pkg <包名> [--aur]：已装则跳过，否则 sudo pacman -S（官方）或 yay -S（AUR）
ensure_pkg() {
    local pkg="$1" mode="${2:-}"
    if pacman -Q "${pkg}" >/dev/null 2>&1; then
        echo "[skip] ${pkg} 已安装"
        return 0
    fi
    if [[ "${mode}" == "--aur" ]]; then
        command -v yay >/dev/null || { echo "[err] 需要 yay 但未安装"; return 1; }
        echo "[inst] yay -S ${pkg} ..."
        yay -S --needed --noconfirm "${pkg}"
    else
        echo "[inst] sudo pacman -S ${pkg} ..."
        sudo pacman -S --needed --noconfirm "${pkg}"
    fi
}

# ensure_symlink <真实文件> <软链>：指向正确则跳过；否则原子替换为软链——
# 先建临时软链再用 mv -T 一步换位，目标路径任何时刻都不为空（不会出现
# 『删除后、链接前』的窗口期）；目标为内容不同的真实文件时先备份再替换。
ensure_symlink() {
    local target="$1" link="$2"
    local linkdir cur bak tmp
    linkdir="$(dirname "${link}")"
    mkdir -p "${linkdir}"
    if [[ -L "${link}" ]]; then
        cur="$(readlink "${link}")"
        if [[ "${cur}" == "${target}" ]]; then
            echo "[skip] 软链已就位: ${link} -> ${target}"
            return 0
        fi
        echo "[fix ] 替换旧软链: ${link} (原指向 ${cur})"
    elif [[ -e "${link}" || -d "${link}" ]]; then
        if [[ -f "${link}" ]] && cmp -s "${link}" "${target}"; then
            echo "[adopt] 内容与仓库一致，替换为软链: ${link}"
        else
            bak="${link}.bak.$(date +%Y%m%d%H%M%S)"
            echo "[backup] 发现真实文件，备份到 ${bak}"
            cp -a "${link}" "${bak}"
        fi
    fi
    tmp="${link}.$$.tmp"
    ln -s "${target}" "${tmp}"
    mv -Tf "${tmp}" "${link}"
    echo "[ok  ] ${link} -> ${target}"
}

# ensure_rc_line <rc文件> <行>：行已存在则跳过，否则原样追加（缺失的文件/目录自动创建）
ensure_rc_line() {
    local rcfile="$1" line="$2"
    mkdir -p "$(dirname "${rcfile}")"
    [[ -f "${rcfile}" ]] || : > "${rcfile}"
    if grep -Fqx "${line}" "${rcfile}"; then
        echo "[skip] ${rcfile} 已有此行: ${line}"
        return 0
    fi
    printf '%s\n' "${line}" >> "${rcfile}"
    echo "[ok  ] ${rcfile} 追加: ${line}"
}
