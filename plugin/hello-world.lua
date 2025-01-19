vim.api.nvim_create_user_command('Rect', function()
  require('hello-world').createRect()
end, {})
