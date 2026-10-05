-- gitui（<leader>gg）
--
-- 注意：gitui **不是 nvim 插件**，它是 Arch 官方源 extra/gitui 里那个
-- 独立的 Rust 终端程序（sudo pacman -S gitui）。
--
-- 这里做的事情只有一件：把它开在 nvim 的一个铺满整个编辑区的浮窗里。
-- 干活的是 snacks 的 terminal 模块（就是 nvim 自带的 :terminal），
-- 所以复用 folke/snacks.nvim 这条 spec，不引入任何新插件。
--
-- 为什么用浮窗而不是分屏或"占满当前窗口"：
--   浮窗关掉（按 q）时只是把浮窗收起来，你原来的窗口布局和 buffer 一个都不动。
--   分屏会真的多切一个窗口出来；position = "current" 更狠，
--   它直接把你当前窗口的 buffer 换成终端，关的时候那个窗口就没了。
--
-- width = 0 / height = 0 在 snacks 里表示"占满"。
-- 别写成 1：snacks 的规则是 <1 按比例算、=0 占满、>=1 当绝对格数，
-- 所以 height = 1 是"只有 1 行高"。
return {
    {
        "folke/snacks.nvim",
        keys = {
            {
                "<leader>gg",
                function()
                    -- gitui 是外部程序，没装的话 nvim 会甩一个看不懂的报错，先自己查一下
                    if vim.fn.executable("gitui") == 0 then
                        vim.notify("没找到 gitui，先安装：sudo pacman -S gitui", vim.log.levels.WARN)
                        return
                    end

                    -- 配色和按键配置都放在本仓库的 gitui/ 里，跟着仓库走 git。
                    --
                    -- 这两个参数都是传**绝对路径**：gitui 的 -t 内部是
                    --     confpath.join(arg_theme)        // src/args.rs
                    -- 而 Rust 的 PathBuf::join 规则是「参数是绝对路径时直接替换掉前面」；
                    -- -k 更直接，源码里就是原样用你给的路径。实测都生效。
                    --
                    -- stdpath("config") 是 ~/.config/nvim，它是指向本仓库的软链接，
                    -- 所以算出来的就是仓库里的那两个文件
                    local dir = vim.fn.stdpath("config") .. "/gitui"
                    local theme = dir .. "/theme.ron"
                    local keys = dir .. "/key_bindings.ron"

                    -- gitui 走的是 libgit2，对 SSH 地址**只认 ssh-agent 里的钥匙**，
                    -- 不读 ~/.ssh 下的密钥文件（asyncgit 里写死了 Cred::ssh_key_from_agent）。
                    -- 所以机器上没跑 agent 时，它的 fetch/pull/push 都会报一句自己编的
                    -- "git error:Bad credentials."（那句不是 GitHub 说的）。
                    --
                    -- "ssh-agent <命令>" 这个写法会临时起一个 agent，命令结束时
                    -- 把它一起收掉，不留后台进程 —— 于是不用改 ~/.ssh/config、
                    -- 也不用动 shell 配置，换台电脑直接能用。
                    --
                    -- ssh-add 不带参数就是加 ~/.ssh 下的默认密钥；</dev/null 是为了
                    -- 密钥万一有口令时立刻失败，而不是弹个提示把 nvim 卡住。
                    --
                    -- 但如果环境里本来就有 agent（比如你手动 ssh-add 过，或密钥在
                    -- ~/.ssh/config 里指定了非默认文件名），那就直接用它，别另起。
                    local cmd
                    if vim.env.SSH_AUTH_SOCK and vim.env.SSH_AUTH_SOCK ~= "" then
                        cmd = { "gitui", "-t", theme, "-k", keys }
                    else
                        cmd = {
                            "ssh-agent",
                            "sh", "-c",
                            'ssh-add </dev/null 2>/dev/null; exec gitui -t "$1" -k "$2"',
                            "sh", -- $0，占位用
                            theme,
                            keys,
                        }
                    end

                    Snacks.terminal(cmd, {
                        -- gitui 里按 ⇧I 打开文件时用哪个编辑器，是它自己从环境变量里找的，
                        -- 顺序是 GIT_EDITOR → git config core.editor → $VISUAL → $EDITOR → vi
                        -- （src/popups/externaleditor.rs）。
                        -- 所以不能指望别的机器上 $EDITOR 是 nvim（可能是 vi / nano），
                        -- 这里把优先级最高的 GIT_EDITOR 显式钉成当前这个 nvim。
                        -- 用 v:progpath 而不是写死 "nvim"，换了二进制名或 PATH 也准。
                        env = { GIT_EDITOR = vim.v.progpath },
                        win = { position = "float", width = 0, height = 0 },
                    })
                end,
                desc = "打开 gitui",
            },
        },
    },
}
