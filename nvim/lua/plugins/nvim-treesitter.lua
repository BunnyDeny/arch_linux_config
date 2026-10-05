-- 语法高亮插件：用语法树（而不是正则）来解析代码，所以高亮更准确
--
-- 【2026-10 从 master 换成 main】
-- 这个插件有两个互不兼容的分支：
--   master  老架构，自带 highlight 模块，写死了只兼容 nvim 0.11，官方已经冻结
--   main    重写版，要求 nvim 0.12+，高亮交给 nvim 原生（vim.treesitter.start）
-- 你的 nvim 是 0.12.5，跑 master 是官方不支持的组合，会报这个错：
--   Decoration provider "start" (ns=nvim.treesitter.highlighter)
--   .../treesitter.lua:197: attempt to call method 'range' (a nil value)
-- 换到 main 就是官方给的修法，换完 picker 预览不再报错。
--
-- 【依赖】
-- main 是现下载 parser 源码在本地编译的，要求 PATH 里有 tree-sitter-cli、tar、curl
-- 和一个 C 编译器。Arch 上 tree-sitter-cli 是单独的包（tree-sitter 那个包只是
-- 那个 C 库，不含命令行工具）：
--   sudo pacman -S tree-sitter-cli
-- 缺了它 install() 只会静默失败，所以下面真的需要装 parser 时会主动检查并提醒。
--
-- 【两个容易踩的坑】
--   * 不要写 main = "nvim-treesitter.config"
--     网上有这个说法，但 main 分支的 config.lua 里只有 setup/get_installed
--     这些，没有 install；写了它 require("nvim-treesitter") 就取不到 install()
--   * master 分支上根本没有 install（实测是 nil），
--     所以换分支和换下面这段 config 必须一起做，不能只改一半

-- main 编译 parser 需要的外部命令。缺任何一个，
-- install() 只会写一条日志然后失败，界面上什么都不显示，所以得自己先查。
local function missing_build_deps()
    local missing = {}

    for _, cmd in ipairs({ "tree-sitter", "tar", "curl" }) do
        if vim.fn.executable(cmd) == 0 then
            missing[#missing + 1] = cmd
        end
    end

    -- 编译器不一定叫 cc，别的发行版可能只有 gcc 或 clang
    if
        vim.fn.executable("cc") == 0
        and vim.fn.executable("gcc") == 0
        and vim.fn.executable("clang") == 0
    then
        missing[#missing + 1] = "C 编译器(cc/gcc/clang)"
    end

    return missing
end

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    -- main 的 README 明确写了 "This plugin does not support lazy-loading"，
    -- 所以不延迟加载。顺带的好处是它在 FileType 之前就加载完了，
    -- 于是教程里那句手动补触发 FileType 的代码这里不需要
    lazy = false,
    -- 插件升级后必须把所有 parser 更新到它期望的版本，让 lazy 自动跑
    build = ":TSUpdate",
    config = function()
        local nvim_treesitter = require("nvim-treesitter")
        -- 这里的 install_dir 不是可选项，必须传：
        -- main 把 parser 装到这里，把 queries 以 symlink 的方式链到这里，
        -- 但 lazy 会重建 runtimepath，实测 ~/.local/share/nvim/site 根本不在 rtp 里，
        -- 不传的话装完了也搜不到 —— 表现是「装成功了但没高亮」。
        -- 传了之后 config.lua 会把这个目录前置到 rtp 最前面，优先级高于插件目录。
        nvim_treesitter.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })

        local parsers = { "lua", "rust" }
        local pattern = {}
        local to_install = {}
        for _, parser in ipairs(parsers) do
            -- inspect 是 nvim 自带 api，parser 不存在会直接报错，所以先 pcall 探一下
            if pcall(vim.treesitter.language.inspect, parser) then
                -- 只为装好的 parser 收集文件类型：
                -- 对没有 parser 的文件类型调 vim.treesitter.start() 会报错
                pattern = vim.tbl_extend("keep", pattern, vim.treesitter.language.get_filetypes(parser))
            else
                to_install[#to_install + 1] = parser
            end
        end

        -- 只有真的缺 parser 时才提依赖的事，否则每次开 nvim 都提醒就是噪音
        if #to_install > 0 then
            local missing = missing_build_deps()
            if #missing > 0 then
                -- 这里只提醒，不自动装：装系统包要 sudo，
                -- 而且往你机器上装东西这事该由你知道、你决定
                vim.notify(
                    string.format(
                        "nvim-treesitter: 缺 %s，装不了 parser（%s）\nArch 上执行：sudo pacman -S tree-sitter-cli",
                        table.concat(missing, "、"),
                        table.concat(to_install, "、")
                    ),
                    vim.log.levels.WARN
                )
            else
                -- 这个调用是异步的：这次仍然没有高亮，装好之后下次进来才有。
                -- 万一还是失败，用 :TSLog 打开本插件自己的日志看原因
                nvim_treesitter.install(to_install)
            end
        end

        -- main 分支没有 highlight = { enable = true } 这种开关，得自己启动高亮，
        -- 所以到上面收集到的文件类型时才调 vim.treesitter.start()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = pattern,
            callback = function()
                vim.treesitter.start()
            end,
        })
    end,
}
