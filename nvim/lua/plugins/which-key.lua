-- 快捷键提示插件：按下前缀键（比如空格）时弹出面板，列出接下来能按什么
return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        -- 按完前缀键后隔多久弹出（毫秒）。它独立于 timeoutlen，
        -- 所以调这个不会影响你按快捷键的速度
        delay = 300,

        -- 给 <leader> 下面每个字母起个组名。
        -- 不写这些的话，弹窗里只显示光秃秃的 b / f / l / h / u，看不出是哪一类
        spec = {
            { "<leader>b", group = "buffer" },
            { "<leader>f", group = "模糊查找" },
            { "<leader>g", group = "git" },
            { "<leader>l", group = "LSP" },
            { "<leader>h", group = "跳转" },
            { "<leader>u", group = "界面 / 开关" },
        },
    },
}
