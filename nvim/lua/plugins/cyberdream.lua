-- cyberdream：透明优先的赛博/霓虹风主题
-- 仓库：https://github.com/scottmckendry/cyberdream.nvim
--
-- 它是**为透明终端设计**的（官方自己的描述就是 transparent-first），
-- 所以默认就不画背景 —— 正好配合你 kitty 那边新开的 background_opacity，
-- 不需要额外加任何开关。
--
-- 主题不能懒加载，必须启动时就加载好，否则会先闪一下默认配色
-- （和之前 fluoromachine 一个道理：lazy = false + priority 拉高）。
--
-- 它还有一批可调项（透明度开关、斜体注释、终端调色板、muted 之类的配色变体…），
-- 具体字段名以仓库 README 为准 —— 我这边打不开任何网页（web_fetch 被挡）、
-- shell 也起不来（没法 clone），核实不了，所以没往里写，
-- 免得写一个不存在的字段。要加的时候照 README 的表填进下面的 opts = {} 即可。
return {
    "scottmckendry/cyberdream.nvim",

    lazy = false,
    priority = 1000,

    opts = {},

    config = function(_, opts)
        require("cyberdream").setup(opts)
        vim.cmd("colorscheme cyberdream")
    end,
}
