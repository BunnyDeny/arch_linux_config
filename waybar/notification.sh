#!/bin/sh
# waybar "custom/notification" 模块的后端 —— 适配 mako。
#
# 背景：原配置是照着 swaync 写的（swaync-client -swb 是一套流式 JSON 协议），
# mako 没有对应协议，所以改成轮询 makoctl 自己组装 JSON。
#
# 输出 waybar custom 模块要求的 JSON，"class" 用于匹配 config.jsonc 里的 format-icons：
#   none / notification / dnd-none / dnd-notification
#
# 依赖：mako（提供 makoctl）、python3（本机没装 jq，用 python3 数数组元素）。
# makoctl 未安装或调用失败时不会报错，退化成灰铃铛 class="none"。

set -u

# mako 未安装时不产生任何错误输出，只显示普通铃铛
if ! command -v makoctl >/dev/null 2>&1; then
	printf '{"text":"","class":"none","tooltip":"mako 未安装"}\n'
	exit 0
fi

# mako 的免打扰是一个名为 do-not-disturb 的模式
if makoctl mode 2>/dev/null | grep -qx 'do-not-disturb'; then
	dnd='dnd-'
	dnd_text='免打扰开启 · '
else
	dnd=''
	dnd_text=''
fi

# makoctl list -j 输出的是 JSON 数组；数元素个数（对解析失败做容错）
count=$(makoctl list -j 2>/dev/null | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    print(len(d) if isinstance(d, list) else 0)
except Exception:
    print(0)
' 2>/dev/null)
count=${count:-0}
case "$count" in
	''|*[!0-9]*) count=0 ;;
esac

if [ "$count" -gt 0 ]; then
	state='notification'
else
	state='none'
fi

printf '{"text":"","class":"%s%s","tooltip":"%s%s 条通知"}\n' \
	"$dnd" "$state" "$dnd_text" "$count"
