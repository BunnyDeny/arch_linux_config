-- buffer TUI显示插件
return {
    "akinsho/bufferline.nvim",

    -- 文件图标插件
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    opts = {
        options = {
            diagnostics = "nvim_lsp",
            diagnostics_indicator = function (_, _, diagnostics_dict, _)
                local indicator = " "
                for level, number in pairs(diagnostics_dict) do
                    local symbol
                    if level == "error" then
                        symbol = " "
                    elseif level == "warning" then
                        symbol = " "
                    else
                        symbol = " "
                    end
                    indicator = indicator .. number .. symbol
                end
                return indicator
            end
        }
    },

    -- 定义一些快捷键
    keys = {
        -- 切换到左侧的 buffer
        { "<leader>bh", ":BufferLineCyclePrev<CR>", desc = "切换到左侧的 buffer", silent = true },

        -- 切换到右侧的 buffer
        { "<leader>bl", ":BufferLineCycleNext<CR>", desc = "切换到右侧的 buffer", silent = true },

        -- 关闭当前 buffer
        { "<leader>bd", ":bdelete<CR>", desc = "关闭当前 buffer", silent = true },

        -- 关闭其他 buffer
        { "<leader>bo", ":BufferLineCloseOthers<CR>", desc = "关闭其他 buffer", silent = true },

        -- 选中特定 buffer（按下后，buffer 旁边会出现字母，按下对应字母跳转到该 buffer）
        { "<leader>bp", ":BufferLinePick<CR>", desc = "选中特定 buffer（弹字母跳转）", silent = true },

        -- 关闭特定 buffer
        { "<leader>bc", ":BufferLinePickClose<CR>", desc = "关闭特定 buffer（弹字母选择）", silent = true },
    },

    -- 禁止懒加载
    lazy = false,
}

