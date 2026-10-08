-- ctrl+z:撤销更改
-- vim.keymap.set({ "n", "i" }, "<C-z>", "<Cmd>undo<CR>", { silent = true })

-- ── <leader>h 组：函数级跳转 ────────────────────────────────
-- 基于语法树精确跳转（nvim-treesitter-textobjects）：
--   只认"函数"节点，if / for / impl 之类的普通块不会误触发；
--   lua / rust / c 都能跳（需要对应语言的 treesitter parser 已安装）。
-- 跳转后会写入 jumplist，可用 <C-o> / <C-i> 原路返回
--
-- 按键约定：j = 向下(下一个)，k = 向上(上一个)；小写 = 函数开头，大写 = 函数结尾
local function jump(method)
    return function()
        require("nvim-treesitter-textobjects.move")[method]("@function.outer", "textobjects")
    end
end

vim.keymap.set("n", "<leader>hj", jump("goto_next_start"), { desc = "下一个函数开头", silent = true })
vim.keymap.set("n", "<leader>hk", jump("goto_previous_start"), { desc = "上一个函数开头", silent = true })
vim.keymap.set("n", "<leader>hJ", jump("goto_next_end"), { desc = "下一个函数结尾", silent = true })
vim.keymap.set("n", "<leader>hK", jump("goto_previous_end"), { desc = "上一个函数结尾", silent = true })

