-- 语法高亮插件：用语法树（而不是正则）来解析代码，所以高亮更准确
local parsers = { "lua", "rust", "c" }

local function missing_build_deps()
    local missing = {}
    for _, cmd in ipairs({ "tree-sitter", "tar", "curl" }) do
        if vim.fn.executable(cmd) == 0 then
            missing[#missing + 1] = cmd
        end
    end
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
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local nvim_treesitter = require("nvim-treesitter")
        nvim_treesitter.setup({
            ensure_installed = parsers,
            install_dir = vim.fn.stdpath("data") .. "/site",
        })

        -- 找出还没装的 parser。nvim-treesitter 的 install 是异步任务，
        -- 直接调用（fire-and-forget）的话 nvim 一退出任务就被杀掉，永远装不完。
        -- 这里用 task:pwait() 阻塞等它装完（pwait 内部会泵事件循环）。
        local installed = nvim_treesitter.get_installed()
        local to_install = {}
        for _, parser in ipairs(parsers) do
            if not vim.list_contains(installed, parser) then
                to_install[#to_install + 1] = parser
            end
        end
        if #to_install > 0 then
            local missing = missing_build_deps()
            if #missing > 0 then
                vim.notify(
                    string.format(
                        "nvim-treesitter: 缺 %s，装不了 parser（%s）\n"
                            .. "Debian/Ubuntu 上执行：sudo apt install tree-sitter-cli tar curl gcc",
                        table.concat(missing, "、"),
                        table.concat(to_install, "、")
                    ),
                    vim.log.levels.WARN
                )
            else
                vim.notify(
                    "nvim-treesitter: 正在编译安装 parser（" .. table.concat(to_install, "、") .. "），首次需要一点时间…",
                    vim.log.levels.INFO
                )
                local task = nvim_treesitter.install(to_install, { summary = true })
                local ok, err = task:pwait(10 * 60 * 1000) -- 最多等 10 分钟
                if not ok then
                    vim.notify("nvim-treesitter: parser 安装失败：" .. tostring(err), vim.log.levels.ERROR)
                end
            end
        end

        -- 装完之后重新算一遍哪些 filetype 有 parser，只给它们挂 FileType autocmd。
        --
        -- 注意 pattern 不能是空表：nvim_create_autocmd 的空 pattern 会匹配所有
        -- filetype（等于 "*"），netrw 之类没有 parser 的 filetype 也会触发
        -- vim.treesitter.start()，在 nvim 0.10 上会直接报错。
        local pattern = {}
        installed = nvim_treesitter.get_installed()
        for _, parser in ipairs(parsers) do
            if vim.list_contains(installed, parser) then
                local ok, fts = pcall(vim.treesitter.language.get_filetypes, parser)
                if ok then
                    pattern = vim.list_extend(pattern, fts)
                end
            end
        end
        if #pattern > 0 then
            vim.api.nvim_create_autocmd("FileType", {
                pattern = pattern,
                callback = function()
                    -- pcall 兜底：万一某个 filetype 没 parser，别让回调炸掉
                    pcall(vim.treesitter.start)
                end,
            })
        end
    end,
}
