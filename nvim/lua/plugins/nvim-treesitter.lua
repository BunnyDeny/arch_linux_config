-- 语法高亮插件：用语法树（而不是正则）来解析代码，所以高亮更准确
local function missing_build_deps()
    local missing = {}
    for _, cmd in ipairs({ "tree-sitter", "tar", "curl" }) do
        if vim.fn.executable(cmd) == 0 then
            missing[#missing + 1] = cmd
        end
    end
    if
        vim.fn.executable("cc") == 0
        and vim.fn.executable("gcc") == 0
        and vim.fn.executable("clang") == 0
    then
        missing[#missing + 1] = "C 编译器(cc/gcc/clang)"
    end
    return missing
end

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local nvim_treesitter = require("nvim-treesitter")
        nvim_treesitter.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
        local parsers = { "lua", "rust", "c" }
        local pattern = {}
        local to_install = {}
        for _, parser in ipairs(parsers) do
            if pcall(vim.treesitter.language.inspect, parser) then
                pattern = vim.list_extend(pattern, vim.treesitter.language.get_filetypes(parser))
            else
                to_install[#to_install + 1] = parser
            end
        end

        if #to_install > 0 then
            local missing = missing_build_deps()
            if #missing > 0 then
                vim.notify(
                    string.format(
                        "nvim-treesitter: 缺 %s，装不了 parser（%s）\nArch 上执行：sudo pacman -S tree-sitter-cli",
                        table.concat(missing, "、"),
                        table.concat(to_install, "、")
                    ),
                    vim.log.levels.WARN
                )
            else
                nvim_treesitter.install(to_install)
            end
        end
        vim.api.nvim_create_autocmd("FileType", {
            pattern = pattern,
            callback = function()
                vim.treesitter.start()
            end,
        })
    end,
}
