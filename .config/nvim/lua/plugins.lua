return require('packer').startup(function(use)
    -- Plugins can have dependencies on other plugins
    use {
    'haorenW1025/completion-nvim',
    opt = true,
    requires = {{'hrsh7th/vim-vsnip', opt = true}, {'hrsh7th/vim-vsnip-integ', opt = true}}
    }
end)
