-- 80 年代合成器浪潮（synthwave）风格的主题，带霓虹发光效果
return {
    "maxmx03/fluoromachine.nvim",

    -- 主题不能懒加载，必须启动时就加载好，否则会先闪一下默认配色
    lazy = false,
    priority = 1000, -- 优先级拉高，保证它比其他插件先加载

    opts = {
        theme = "retrowave", -- 可选 fluoromachine / retrowave / delta
        glow = true,             -- 霓虹发光效果，就是它最标志性的那个感觉

        -- true → nvim 不画背景色，露出 kitty 的底色（配合 kitty 的
        --        background_opacity 就是透明的；关了它就是纯色）
        -- false → nvim 自己画背景色（glow 模式下是 #200933 深紫），
        --         整个窗口颜色统一，但会盖掉 kitty 的透明度
        --
        -- 注意：kitty 的 background_opacity 只对「背景色 == 终端默认背景色」的格子
        -- 生效，所以只要 nvim 画了底色，透明度就看不出来 —— 这就是之前不透明的
        -- 原因。要让霓虹配色好看，可以把 kitty 的 background 也改成 #200933。
        transparent = true,
    },
    config = function(_, opts)
        require("fluoromachine").setup(opts)
        vim.cmd("colorscheme fluoromachine")
    end,
}
