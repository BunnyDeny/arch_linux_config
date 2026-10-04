-- buffer TUI显示插件
return {
    "akinsho/bufferline.nvim",

    -- 文件图标插件
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    -- 只有设置了opts或者config，lazy才会setup插件
    opts = {},

    -- 定义一些快捷键
    keys = {
        -- 切换到左侧的 buffer
        { "<leader>bh", ":BufferLineCyclePrev<CR>", silent = true },

        -- 切换到右侧的 buffer
        { "<leader>bl", ":BufferLineCycleNext<CR>", silent = true },

        -- 关闭当前 buffer
        { "<leader>bd", ":bdelete<CR>", silent = true },

        -- 关闭其他 buffer
        { "<leader>bo", ":BufferLineCloseOthers<CR>", silent = true },

        -- 选中特定 buffer（按下后，buffer 旁边会出现字母，按下对应字母跳转到该 buffer）
        { "<leader>bp", ":BufferLinePick<CR>", silent = true },

        -- 关闭特定 buffer
        { "<leader>bc", ":BufferLinePickClose<CR>", silent = true },
    },

    -- 禁止懒加载
    lazy = false,
}

