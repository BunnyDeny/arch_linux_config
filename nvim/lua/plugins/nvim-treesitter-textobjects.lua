-- 语法树级函数跳转插件：精确按"函数"节点跳转（不会把 if/impl 当成函数）。
-- 配合 core/keymap.lua 里的 <leader>h[ / h] / h{ / h} 使用
return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },

    -- 不懒加载：它只是注册配置和查询文件，本体极小；
    -- 而且 keymap.lua 里的映射会在启动时就引用它的 move 模块
    lazy = false,

    config = function()
        require("nvim-treesitter-textobjects").setup({
            move = {
                -- 跳转时写入 jumplist，跳完可以用 <C-o> 原路返回
                set_jumps = true,
            },
        })
    end,
}
