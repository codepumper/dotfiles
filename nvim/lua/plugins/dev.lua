return {

  {
    'gn0/nvim-web-server',
    config = function()
      local serve = function()
        local buf = vim.api.nvim_get_current_buf()
        require('web-server').init()
        vim.api.nvim_set_current_buf(buf)
        local ft
        if vim.bo[buf].filetype == 'html' then
          ft = 'text/html'
        elseif vim.api.nvim_buf_get_name(buf):match 'png$' then
          ft = 'image/png'
        end
        vim.cmd([[WSAddBuffer / ]] .. ft)
      end
      vim.keymap.set('n', '<leader>ws', serve, { desc = 'Start web server' })
    end,
  },

  { -- profile your config to see what code is executed
    'stevearc/profile.nvim',
    enabled = true,
    config = function()
      local should_profile = os.getenv 'NVIM_PROFILE'
      if should_profile then
        require('profile').instrument_autocmds()
        if should_profile:lower():match '^start' then
          require('profile').start '*'
        else
          require('profile').instrument '*'
        end
      end

      local function toggle_profile()
        local prof = require 'profile'
        if prof.is_recording() then
          prof.stop()
          vim.ui.input(
            { prompt = 'Save profile to:', completion = 'file', default = 'profile.json' },
            function(filename)
              if filename then
                prof.export(filename)
                vim.notify(string.format('Wrote %s', filename))
              end
            end
          )
        else
          prof.start '*'
        end
      end
      vim.keymap.set('', '<f1>', toggle_profile)
    end,
  },
  {
    'KeepDrive/tts.nvim',
  },
}
