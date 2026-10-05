-- folke/snacks.nvim —— 一个"瑞士军刀"式的插件，很多小功能都塞在里面。
-- 这个文件目前只用了它的 picker 模块（模糊查找，替代了之前的 fzf-lua）。
--
-- picker 和之前的 fzf-lua 最本质的区别：snacks 是纯 Lua 实现，搜索结果列表
-- 就是 nvim 自己的 buffer，所以有真正的 normal / insert 模式：
--   打开后是 insert 模式，直接打字搜索
--   按 <Esc>   → 进 normal 模式
--   按 j / k   → 在结果列表里上下移动（不用按方向键）
--   按 i       → 回 insert 模式继续改搜索词
return {
    "folke/snacks.nvim",

    -- README 明确要求：有些插件需要在很早的时机就能用到 snacks 的 setup
    priority = 1000,
    lazy = false,

    opts = {
        -- 启用 picker 模块。
        -- snacks 的规则是「传进 opts 的模块才启用」，所以没写在这里的模块都不会加载 ——
        -- 这一点很重要，因为 snacks 自带 explorer（会和 nvim-tree 撞）、
        -- indent（会和 indent-blankline 撞）等一堆模块，不显式启用就不会被带上
        picker = {
            enabled = true,

            sources = {
                -- zoxide 按回车时执行的动作，内置默认是 "load_session"。
                --
                -- 注意别改成 "cd"：snacks 的 M.cd 只做 chdir，**不关 picker**，
                -- 所以看起来会像"回车没反应"（其实目录已经切了）。
                -- "load_session" 才会先 picker:close() 再 chdir，
                -- 关掉之后还会直接列出那个目录下的文件
                zoxide = {
                    confirm = "load_session",
                },
            },
        },
    },

    keys = {
        -- 模糊查找文件并打开
        { "<leader>ff", function() Snacks.picker.files() end, desc = "模糊查找文件" },

        -- 全项目搜索内容（边打字边出结果）
        { "<leader>fg", function() Snacks.picker.grep() end, desc = "全项目搜索内容" },

        -- 模糊选一个最近访问过的目录并 cd 过去。
        -- 数据来源和你终端里的 cdi 完全一样（同一个 zoxide 数据库）
        { "<leader>fz", function() Snacks.picker.zoxide() end, desc = "跳到最近目录 (zoxide)" },

        -- 最近打开过的文件
        { "<leader>fo", function() Snacks.picker.recent() end, desc = "最近打开的文件" },
    },
}
