-- 代码格式化插件，目前支持的语言有：lua，rust
return {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    config = function()
        local registry = require("mason-registry")

        local function install(name)
            local success, package = pcall(registry.get_package, name)
            if success and not package:is_installed() then
                package:install()
            end
        end

        install("stylua")
        -- rustfmt 不用装：rustup 里已经有了

        local null_ls = require("null-ls")

        -- none-ls 没有内置 rustfmt，所以自己定义一个，内容就是调外部命令
        local h = require("null-ls.helpers")
        local methods = require("null-ls.methods")

        local rustfmt = h.make_builtin({
            name = "rustfmt",
            method = methods.internal.FORMATTING,
            filetypes = { "rust" },
            generator_opts = {
                command = "rustfmt",
                args = { "--emit=stdout", "--edition", "2024" },
                to_stdin = true,
            },
            factory = h.formatter_factory,
        })

        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.stylua,
                rustfmt,
            },
        })
    end,
    keys = {
        {
            "<leader>lf",
            function()
                vim.lsp.buf.format()
            end,
            desc = "格式化当前文件",
        }
    },
}
