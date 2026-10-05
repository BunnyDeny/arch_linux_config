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
        actions = {
            open_file = {
                quit_on_open = true,
            },
        },
    },
    keys = {
        { "<leader>uf", ":NvimTreeToggle<CR>", desc = "开关文件树" },
    },
}

