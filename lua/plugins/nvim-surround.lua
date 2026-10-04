-- 用法一：
-- 用指定字符包裹motion内容：
-- ys<motion><c> 
-- <c>表示包裹要用的字符

-- 用法二：
-- 用指定字符包裹visual选区内容：
-- 指定了visual选区之后，按S<c>即可用<c>包裹选区的内容
--
-- 用法三：
-- 删除包裹符号
-- 假设一段内容被一对双引号包裹，且我们的光标位于这对双引号内部，那么我们就可以通过 ds" 来移除双引号
return {
    "kylechui/nvim-surround",

    -- VeryLazy 是一个特殊的事件，由 lazy 包管理器提供，
    -- 一般我们想要懒加载一个插件，但又不知道具体该让它
    -- 什么时候懒加载，就可以设置 event = "VeryLazy"。
    event = "VeryLazy",

    opts = {},
}

