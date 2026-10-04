-- lsp的包管理工具- mason
return {
    "mason-org/mason.nvim",
    event = "VeryLazy",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mason-org/mason-lspconfig.nvim",
    },
    opts = {},
    config = function (_, opts)
        require("mason").setup(opts)
        local registry = require "mason-registry"

        local function setup(name, config)
            local success, package = pcall(registry.get_package, name)
            if success and not package:is_installed() then
                package:install()
            end
            -- mason 的包名 和 lspconfig 的 server 名不一定一样
            -- 比如 lua-language-server 对应的 lspconfig 名字是 lua_ls，所以要通过映射表转换
            local lsp = require("mason-lspconfig").get_mappings().package_to_lspconfig[name]
            vim.lsp.config(lsp, config)
            vim.lsp.enable(lsp)
        end

        -- 以 lua 为例，我们在 mason 中查找得到其 lsp 的名字是 lua-language-server
        setup("lua-language-server", {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" },
                    },
                },
            },
        })

        -- rust：包名 rust-analyzer，映射到的 lspconfig 名字是 rust_analyzer
        -- 和 lua 完全一样的写法，不关心机器上装没装过
        setup("rust-analyzer", {
            settings = {
                ["rust-analyzer"] = {
                    -- 用 clippy 做检查
                    check = { command = "clippy" },
                    -- 检查所有 feature 组合下的代码
                    cargo = { allFeatures = true },
                },
            },
        })

        vim.diagnostic.config({ update_in_insert = true })
    end,
}
