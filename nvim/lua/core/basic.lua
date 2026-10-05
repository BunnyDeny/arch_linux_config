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

-- 因为有了 lualine 来显示 mode，就不需要 neovim 自己在左下角显示
-- mode 了。通过下面的代码将其禁用
vim.opt.showmode = false

-- 将选剪切板器默认设置为+寄存器和unname寄存器以实现系统剪切板互通
--
-- 补充：下面这一行只负责把寄存器【接到】+ 上，它本身不提供剪贴板的读写能力。
-- 那个能力来自 nvim 的 clipboard provider，也就是一个外部程序。
-- Wayland 环境下需要装 wl-clipboard（提供 wl-copy / wl-paste）：
--     sudo pacman -S wl-clipboard
-- 不装的话 has("clipboard") 会是 0 —— 表现是 yy 复制了、粘出来却是空的，
-- 而且全程不报错（nvim 只是找不到任何可用的剪贴板工具）。
-- 另外这行会立刻触发 provider 初始化，所以必须有一个"同步就能找到"的工具，
-- 不能只依赖 OSC52 那种需要等终端回应的探测（时序不稳，实测会失败）。
vim.opt.clipboard = "unnamedplus"
