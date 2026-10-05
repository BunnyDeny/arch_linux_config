-- 底部状态栏
--
-- 配色直接写死在这里，想改哪个改哪个，不需要懂任何逻辑。
-- 代价：换 nvim 主题时这些颜色不会自动跟着变，得回来手动调，
-- 但这正是"自己指定颜色"的含义。

-- 底色 / 状态栏底色 / 普通文字，取自你现在用的 fluoromachine(retrowave) 配色
local bg = "#262335"
local dark = "#241b2f"
local fg = "#f8f8f8"

-- 每个模式的强调色。想换颜色只改这里。
local colors = {
    normal = "#af6df9", -- 紫
    insert = "#72f1b8", -- 绿
    visual = "#61e2ff", -- 青
    replace = "#fe4450", -- 红
    command = "#ff8b39", -- 橙
}

-- lualine 的状态栏分三段：
--   a = 模式名那块（NORMAL / INSERT ...），铺成强调色，文字用底色
--   b = 文件名、git 分支等，用状态栏底色配强调色文字
--   c = 其余信息，用底色配普通文字
local function mode(accent)
    return {
        a = { bg = accent, fg = bg, gui = "bold" },
        b = { bg = dark, fg = accent },
        c = { bg = bg, fg = fg },
    }
end

local theme = {
    normal = mode(colors.normal),
    insert = mode(colors.insert),
    visual = mode(colors.visual),
    replace = mode(colors.replace),
    command = mode(colors.command),
}
theme.terminal = theme.command

return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    opts = {
        options = {
            theme = theme,
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
        },
        extensions = { "nvim-tree" },
        sections = {
            lualine_b = { "branch", "diff" },
            lualine_x = {
                "filesize",
                "encoding",
                "filetype",
            },
        },
    },
}
