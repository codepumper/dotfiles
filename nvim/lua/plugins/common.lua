return {
  -- common dependencies
  { 'nvim-lua/plenary.nvim' },
  {
    'folke/snacks.nvim',
    dev = false,
    priority = 1000,
    lazy = false,
    opts = {
      styles = {},
      bigfile = { notify = false },
      quickfile = {},
      picker = {
        -- ui_select = false, -- replace `vim.ui.select` with the snacks picker
      },
      indent = {},
      image = {
        enabled = true,
        doc = {
          enabled = true,
          -- inline = false,
          -- float = true,
          max_width = 60,
          max_height = 10,
          -- conceal = true,
        },
        math = {
          enabled = false,
        },
      },
    },
  },
}
