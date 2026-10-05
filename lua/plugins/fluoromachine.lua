-- 80 年代合成器浪潮（synthwave）风格的主题，带霓虹发光效果
return {
    "maxmx03/fluoromachine.nvim",

    -- 主题不能懒加载，必须启动时就加载好，否则会先闪一下默认配色
    lazy = false,
    priority = 1000, -- 优先级拉高，保证它比其他插件先加载

    opts = {
        theme = "retrowave", -- 可选 fluoromachine / retrowave / delta
        glow = true,             -- 霓虹发光效果，就是它最标志性的那个感觉

        -- false → nvim 自己画背景色（glow 模式下是 #200933 深紫），整个窗口颜色统一
        -- true  → 露出 kitty 的底色（你现在是 Catppuccin-Mocha 的 #1e1e2e），
        --         但 fluoromachine 的霓虹配色是围绕紫色底设计的，压在灰蓝底上会不搭
        -- 想用 true，就把 kitty 的 background 也改成 #200933，两边就统一了
        transparent = false,
    },
    config = function(_, opts)
        require("fluoromachine").setup(opts)
        vim.cmd("colorscheme fluoromachine")
    end,
}
