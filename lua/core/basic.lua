-- 显示行号
vim.opt.number = true 

-- 显示相对行号
vim.opt.relativenumber = true

-- 高亮显示当前行
vim.opt.cursorline = true

-- 固定 sign 列的宽度（这一列在行号左边，用来放 💡、诊断标记之类的小图标）
-- 默认值是 auto，意思是「只在有图标要显示时才出现」，所以没图标时宽度是 0，
-- 而 lspsaga 的 💡 一冒出来就会把它撑开 2 格，整段代码跟着右移；
-- 光标移开、💡 消失后又缩回去，代码就左右乱跳
-- yes 系列表示「永远显示」，yes:2 是留出放 2 个图标的空间（每个两格宽度），
--这样就不会再乱跳了
vim.opt.signcolumn = "yes:2"

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

