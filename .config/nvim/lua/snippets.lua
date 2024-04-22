local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local r = require("luasnip.extras").rep

ls.add_snippets("all", {
    s("foo", {
        t("Hello world"),
        i(1),
        t(" and we also edit here: "),
        i(2, "int foo"),
        t("!")
    })
})
