local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
    spec = {
        { import = "plugins" },
    },

    git = {
        -- 本机到 GitHub 的网速很慢（几十 KiB/s），snacks.nvim 完整克隆需要 5~6 分钟。
        -- 默认 120 秒的超时会杀掉还在下载的 git 进程，导致 "Clone succeeded, but
        -- checkout failed"。放宽到 10 分钟。
        timeout = 600,

        -- 默认的 --filter=blob:none 部分克隆会在 checkout 阶段逐个拉取文件，
        -- 慢速网络下极易失败。改成完整克隆：所有内容在 clone 时一次下完，
        -- checkout 变为纯本地操作。
        filter = false,
    },
})

