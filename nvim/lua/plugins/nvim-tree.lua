-- <leader>uf 打开左侧栏文件导航栏，支持一些常见快捷键：
-- a：新建文件
-- d：删除文件
-- y：复制文件名
-- c：复制文件（配合 p 粘贴；y 只复制名字，粘不出文件）
-- p：粘贴
-- x：剪切文件
-- r：重命名
-- Enter：打开文件
--
-- 上面这份清单在打开树的时候会以浮窗形式弹出来（按任意键消失），
-- 内容在下面 config 里的 HINTS 表，改那边才影响提示；这里留着是方便读代码
-- ===========================================================================
-- 树内自动预览：光标移到文件上，右侧浮窗显示内容（仿 <leader>ff 的预览体验）；
-- 移到文件夹或空白处则关闭预览。焦点始终留在树上，按任意键不会被打断。
-- ===========================================================================
local preview_buf = nil
local preview_win = nil
local PREVIEW_MAX_LINES = 200

local function close_preview()
    if preview_win and vim.api.nvim_win_is_valid(preview_win) then
        vim.api.nvim_win_close(preview_win, true) -- bufhidden=wipe，buffer 跟着销毁
    end
    preview_win = nil
    preview_buf = nil
end

local function show_preview(path)
    local lines = vim.fn.readfile(path, "", PREVIEW_MAX_LINES)

    -- 复用同一个 buffer，避免每次移动光标都开新窗闪烁
    if not preview_buf or not vim.api.nvim_buf_is_valid(preview_buf) then
        preview_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[preview_buf].bufhidden = "wipe"
    end

    vim.bo[preview_buf].modifiable = true
    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
    vim.bo[preview_buf].modifiable = false

    -- 按文件名猜 filetype 拿语法高亮；filetype 没变时不会重复触发 FileType 事件
    local ft = vim.filetype.match({ filename = path }) or ""
    if ft ~= vim.bo[preview_buf].filetype then
        vim.bo[preview_buf].filetype = ft
    end

    local width = math.min(84, math.max(60, vim.o.columns - 46))
    if not preview_win or not vim.api.nvim_win_is_valid(preview_win) then
        preview_win = vim.api.nvim_open_win(preview_buf, false, {
            relative = "editor",
            width = width,
            height = vim.o.lines - 4,
            row = 1,
            col = vim.o.columns - width - 2,
            style = "minimal",
            border = "rounded",
            title = " " .. vim.fn.fnamemodify(path, ":t") .. " ",
            title_pos = "center",
            zindex = 5,
        })
    else
        -- 窗口已存在就只更新标题（set_config 是合并语义，其余配置保持不变）
        vim.api.nvim_win_set_config(preview_win, {
            title = " " .. vim.fn.fnamemodify(path, ":t") .. " ",
            title_pos = "center",
        })
    end
end

-- 挂在 nvim-tree 的 on_attach 上：树 buffer 里移动光标时刷新预览
local function attach_auto_preview(bufnr)
    -- 关键：只要自定义了 on_attach，nvim-tree 就不再安装默认键位
    -- （回车展开文件夹、a/d/r 等都靠它）。必须先手动装回来。
    require("nvim-tree.api").config.mappings.default_on_attach(bufnr)

    local group = vim.api.nvim_create_augroup("NvimTreeAutoPreview", { clear = true })

    vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        buffer = bufnr,
        callback = function()
            -- CursorMoved 运行在 textlock 上下文，关闭窗口的操作会被拒绝；
            -- 用 vim.schedule 推迟到事件循环里执行（顺带把连续移动合并成一次更新）
            vim.schedule(function()
                local node = require("nvim-tree.api").tree.get_node_under_cursor()
                -- 文件夹（含符号链接指向的目录）、空白处：什么都不弹，顺手关掉已有预览
                if
                    not node
                    or node.type == "directory"
                    or vim.fn.isdirectory(node.absolute_path) == 1
                    or vim.fn.filereadable(node.absolute_path) == 0
                then
                    close_preview()
                    return
                end
                show_preview(node.absolute_path)
            end)
        end,
    })
end

return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        -- 让树的根目录跟着 :cd 走。默认是 false，也就是 nvim 换了工作目录、
        -- 树还停在原地 —— <leader>fz（zoxide 跳目录）用的是全局 :cd，
        -- 所以不加这行的话，跳完目录树还是显示旧的文件。
        -- 打开时会在 DirChanged 事件上注册 callback 重新挂根
        sync_root_with_cwd = true,

        -- 光标移到文件上自动在右侧浮窗预览（文件夹不弹）
        on_attach = attach_auto_preview,

        actions = {
            open_file = {
                quit_on_open = true,
            },
        },
    },

    config = function(_, opts)
        require("nvim-tree").setup(opts)

        -- 打开树时弹出的提示内容
        local HINTS = {
            "a      新建文件",
            "d      删除文件",
            "y      复制文件名",
            "c      复制文件（配合 p 粘贴）",
            "p      粘贴",
            "x      剪切文件",
            "r      重命名",
            "<CR>   打开文件",
            "",
            "g?     查看完整键位表",
        }

        local function show_hint()
            -- 窗口宽度按最长的一行算，再左右各留 2 格
            local width = 0
            for _, line in ipairs(HINTS) do
                width = math.max(width, vim.fn.strdisplaywidth(line))
            end
            width = width + 4

            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, HINTS)
            vim.bo[buf].modifiable = false
            vim.bo[buf].bufhidden = "wipe"

            -- 第二个参数 false = 不要把光标移进这个浮窗，焦点留在树上
            local win = vim.api.nvim_open_win(buf, false, {
                relative = "editor",
                width = width,
                height = #HINTS,
                row = 2,
                col = vim.o.columns - width - 2,
                style = "minimal",
                border = "rounded",
                title = " 文件树快捷键 ",
                title_pos = "center",
            })

            -- 按任意键关闭。
            -- vim.on_key 是"按键旁听"：不会吃掉按键，只在每次按键时回调一次，
            -- 正好用来做"任意键消失"。
            local ns = vim.api.nvim_create_namespace("nvim_tree_hint")
            vim.on_key(function()
                vim.on_key(nil, ns) -- 先注销自己，避免重复触发
                -- 回调跑在 fast 上下文里，碰 API 要用 vim.schedule 包一层
                vim.schedule(function()
                    if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_win_close(win, true)
                    end
                end)
            end, ns)
        end

        require("nvim-tree.api").events.subscribe("TreeOpen", function()
            -- vim.schedule 是为了等 <leader>uf 这一串按键处理完再挂 on_key，
            -- 否则会被当前这次按键立刻触发，提示窗一闪就没了
            vim.schedule(show_hint)
        end)

        -- 树窗口关闭（<leader>uf 收起、回车打开文件后自动收起都算）→ 关掉预览
        require("nvim-tree.api").events.subscribe("TreeClose", function()
            close_preview()
        end)
    end,

    keys = {
        -- 开关：关着就开、开着就关
        { "<leader>uf", ":NvimTreeToggle<CR>", desc = "开关文件树" },
    },
}

