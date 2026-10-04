-- 语法高亮插件：用语法树（而不是正则）来解析代码，所以高亮更准确
-- 它还能提供缩进、代码折叠、增量选择等功能，这里只开了高亮
return {
    "nvim-treesitter/nvim-treesitter",
    main = "nvim-treesitter.configs",
    branch = "master", -- 详见本系列的附录
    event = "VeryLazy",
    opts = {
        ensure_installed = { "lua", "rust" },
        highlight = { enable = true }
    },
}

