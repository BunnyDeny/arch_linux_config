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
return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        -- 让树的根目录跟着 :cd 走。默认是 false，也就是 nvim 换了工作目录、
        -- 树还停在原地 —— <leader>fz（zoxide 跳目录）用的是全局 :cd，
        -- 所以不加这行的话，跳完目录树还是显示旧的文件。
        -- 打开时会在 DirChanged 事件上注册 callback 重新挂根
        sync_root_with_cwd = true,

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
    end,

    keys = {
        -- 开关：关着就开、开着就关
        { "<leader>uf", ":NvimTreeToggle<CR>", desc = "开关文件树" },
    },
}

