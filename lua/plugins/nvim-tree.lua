-- <leader>uf 打开左侧栏文件导航栏，支持一些常见快捷键：
-- a：新建文件
-- d：删除文件
-- y：复制文件名
-- c：复制文件（配合 p 粘贴；y 只复制名字，粘不出文件）
-- p：粘贴
-- x：剪切文件
-- r：重命名
-- Enter：打开文件
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
    keys = {
        -- 开关：关着就开、开着就关
        { "<leader>uf", ":NvimTreeToggle<CR>", desc = "开关文件树" },
    },
}

