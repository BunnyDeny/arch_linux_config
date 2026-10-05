-- 快速跳转任意位置插件，n模式输入<leader>hp然
-- 后按下高亮的字母跳转到对应的位置
return {
    "smoka7/hop.nvim",
    opts = {
        hint_position = 3,
    },
    keys = {
        { "<leader>hp", "<Cmd>HopWord<CR>", desc = "hop word", silent = true },
    },
}

