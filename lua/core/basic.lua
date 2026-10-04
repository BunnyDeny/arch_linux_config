-- 显示行号
vim.opt.number = true 

-- 显示相对行号
vim.opt.relativenumber = true

-- 高亮显示当前行
vim.opt.cursorline = true

-- tab转换为空格
vim.opt.expandtab = true

-- 每个tab相当于4个空格
vim.opt.tabstop = 4

-- 会将 shiftwidth 设置为和 tabstop 相同的值。
vim.opt.shiftwidth = 0

-- 当其他程序修改了正打开的文件，自动加载文件最新内容
vim.opt.autoread = true

-- 设置leader按键为空格
vim.g.mapleader = " "

-- 如果查找的内容中不存在大写，则大小写不敏感
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 不要在查找之后继续高亮匹配结果
vim.opt.hlsearch = false

