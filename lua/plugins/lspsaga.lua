-- LSP 增强插件：把定义跳转、重命名、代码操作、查找引用这些做成浮动窗口
return {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    opts = {
        finder = {
            -- 查找器里用回车打开选中的项（默认是 o）
            keys = {
                toggle_or_open = "<CR>",
            },
        },
    },

    keys = {
        -- 重命名光标下的符号（带实时预览，回车确认，Ctrl+k 退出，或者ESC之后：q退出）
        { "<leader>lr", ":Lspsaga rename<CR>" },

        -- code action，数字选择，回车确定，q取消
        { "<leader>lc", ":Lspsaga code_action<CR>" },

        -- 跳转到定义处。
        { "<leader>ld", ":Lspsaga goto_definition<CR>" },

        -- 浮窗显示光标下符号的文档，任意方向键取消
        { "<leader>lh", ":Lspsaga hover_doc<CR>" },

        -- 打开查找器，一次列出定义/引用/实现，q退出，回车跳转到选中的项
        { "<leader>lR", ":Lspsaga finder<CR>" },

        -- 跳到下一条诊断（错误/警告）
        { "<leader>ln", ":Lspsaga diagnostic_jump_next<CR>" },

        -- 跳到上一条诊断
        { "<leader>lp", ":Lspsaga diagnostic_jump_prev<CR>" },
    }
}
