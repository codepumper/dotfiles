-- plugins for notetaking and knowledge management

return {
  {
    'nvim-neorg/neorg',
    enabled = false,
    config = function()
      require('neorg').setup {}
    end,
  },

  {
    'jakewvincent/mkdnflow.nvim',
    enabled = false,
    config = function()
      local mkdnflow = require 'mkdnflow'
      mkdnflow.setup {}
    end,
  },

  {
    'epwalsh/obsidian.nvim',
    version = '*',
    enabled = false,
    lazy = false,
    ft = 'markdown',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      { '<leader>nd', ':Obsidian today<cr>', desc = 'obsidian [d]aily' },
      { '<leader>nt', ':e ~/notes/readme.md<cr>', desc = 'obsidian [t]odo' },
      { '<leader>ny', ':Obsidian yesterday<cr>', desc = 'obsidian [y]esterday' },
      { '<leader>nb', ':Obsidian backlinks<cr>', desc = 'obsidian [b]acklinks' },
      { '<leader>nl', ':Obsidian link<cr>', desc = 'obsidian [l]ink selection' },
      { '<leader>nf', ':Obsidian follow_link<cr>', desc = 'obsidian [f]ollow link' },
      { '<leader>nn', ':Obsidian new<cr>', desc = 'obsidian [n]ew' },
      { '<leader>ns', ':Obsidian search<cr>', desc = 'obsidian [s]earch' },
      { '<leader>no', ':Obsidian quick_switch<cr>', desc = 'obsidian [o]pen quickswitch' },
      { '<leader>nO', ':Obsidian open<cr>', desc = 'obsidian [O]pen in app' },
    },
    opts = {
        legacy_commands = false,
        ui = {
          -- checkboxes = { [' '] = {}, ['x'] = {} },
          enable = false,
        },
        workspaces = {
          {
            name = 'notes',
            path = '~/notes',
          },
        },
        -- Optional, for templates (see below).
        templates = {
          folder = 'templates',
          date_format = '%Y-%m-%d',
          time_format = '%H:%M',
          -- A map for custom variables, the key should be the variable and the value a function
          substitutions = {},
        },
        daily_notes = {
          -- Optional, if you keep daily notes in a separate directory.
          -- folder = "dailies",
          -- Optional, if you want to change the date format for the ID of daily notes.
          -- date_format = "%Y-%m-%d",
          -- Optional, if you want to change the date format of the default alias of daily notes.
          -- alias_format = "%B %-d, %Y",
          -- Optional, default tags to add to each new daily note created.
          -- default_tags = { "daily-notes" },
          -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
          template = 'template-daily.md',
        },
        -- Optional, customize how names/IDs for new notes are created.
        note_id_func = function(title)
          -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
          -- In this case a note with the title 'My new note' will be given an ID that looks
          -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
          local suffix = ''
          if title ~= nil then
            -- If title is given, transform it into valid file name.
            suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
          else
            -- If title is nil, just add 4 random uppercase letters to the suffix.
            for _ = 1, 4 do
              suffix = suffix .. string.char(math.random(65, 90))
            end
          end
          return tostring(os.time()) .. '-' .. suffix
        end,
      }
  },
}
