-- 底部状态栏
--
-- 配色直接写死在这里，想改哪个改哪个，不需要懂任何逻辑。
-- 代价：换 nvim 主题时这些颜色不会自动跟着变，得回来手动调，
-- 但这正是"自己指定颜色"的含义。

-- 三个基础颜色，取自你现在用的 fluoromachine(retrowave) 配色
local editor_bg = "#262335" -- 编辑器底色（就是代码区那片深紫）
local status_bg = "#241b2f" -- 状态栏底色，比编辑器底色稍暗一点，用来分层次
local text = "#f8f8f8" -- 普通文字颜色

-- 每个模式的强调色。想换颜色只改这里。
local colors = {
    normal = "#af6df9", -- 紫
    insert = "#72f1b8", -- 绿
    visual = "#61e2ff", -- 青
    replace = "#fe4450", -- 红
    command = "#ff8b39", -- 橙
}

-- lualine 把状态栏分成 a / b / c 三组配色，每组各有一个背景色 bg 和一个文字色 fg。
-- 你的配置里，这三组分别用在这些位置（左右两端是对称的）：
--   a → 最左边 NORMAL / INSERT 那一块，以及最右边的 1:1
--   b → git 分支 / 改动，以及 Top 那种进度显示
--   c → 文件名，以及 filesize / encoding / filetype
local function mode(accent)
    return {
        -- a：铺成强调色，文字用编辑器底色（深色文字配亮色块，对比度天然够）
        a = { bg = accent, fg = editor_bg, gui = "bold" },
        -- b：状态栏底色配强调色文字
        b = { bg = status_bg, fg = accent },
        -- c：编辑器底色配普通文字
        c = { bg = editor_bg, fg = text },
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
