local utils = require('judge.utils')

local M = {}

M.results_buf = nil
M.results_win = nil

function M.create_results_window()
  if M.results_win and vim.api.nvim_win_is_valid(M.results_win) then
    vim.api.nvim_win_close(M.results_win, true)
  end
  
  local width = math.floor(vim.o.columns * utils.config.ui.results_window.width)
  local height = math.floor(vim.o.lines * utils.config.ui.results_window.height)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  if not M.results_buf or not vim.api.nvim_buf_is_valid(M.results_buf) then
    M.results_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(M.results_buf, 'filetype', 'judge-results')
    vim.api.nvim_buf_set_option(M.results_buf, 'bufhidden', 'wipe')
  end
  
  M.results_win = vim.api.nvim_open_win(M.results_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    border = utils.config.ui.results_window.border,
    title = 'Judge Results',
    title_pos = 'center'
  })
  
  vim.api.nvim_win_set_option(M.results_win, 'wrap', false)
  vim.api.nvim_win_set_option(M.results_win, 'cursorline', true)
  
  local keymaps = {
    { 'n', 'q', function() M.close_results_window() end, { buffer = M.results_buf } },
    { 'n', '<ESC>', function() M.close_results_window() end, { buffer = M.results_buf } },
    { 'n', 'r', function() M.refresh_results() end, { buffer = M.results_buf } },
  }
  
  for _, keymap in ipairs(keymaps) do
    vim.keymap.set(keymap[1], keymap[2], keymap[3], keymap[4])
  end
end

function M.close_results_window()
  if M.results_win and vim.api.nvim_win_is_valid(M.results_win) then
    vim.api.nvim_win_close(M.results_win, true)
    M.results_win = nil
  end
end

function M.toggle_results_window()
  if M.results_win and vim.api.nvim_win_is_valid(M.results_win) then
    M.close_results_window()
  else
    M.create_results_window()
  end
end

function M.display_results(results)
  if not M.results_buf or not vim.api.nvim_buf_is_valid(M.results_buf) then
    M.create_results_window()
  end
  
  local lines = {}
  local highlights = {}
  
  table.insert(lines, string.format('Judge Results: %d passed, %d failed', results.passed, results.failed))
  table.insert(lines, string.rep('=', 50))
  table.insert(lines, '')
  
  if results.passed > 0 then
    table.insert(highlights, { line = #lines + 1, group = utils.config.ui.highlights.passed })
  end
  if results.failed > 0 then
    table.insert(highlights, { line = 1, group = utils.config.ui.highlights.failed })
  end
  
  for file, file_results in pairs(results.files) do
    table.insert(lines, string.format('File: %s', file))
    table.insert(lines, string.format('  Passed: %d, Failed: %d', file_results.passed, file_results.failed))
    
    if #file_results.corrections > 0 then
      table.insert(lines, '  Corrections:')
      for _, correction in ipairs(file_results.corrections) do
        for line in correction:gmatch('[^\r\n]+') do
          if line:match('^%-') then
            table.insert(lines, '    ' .. line)
            table.insert(highlights, { line = #lines, group = utils.config.ui.highlights.diff_removed })
          elseif line:match('^%+') then
            table.insert(lines, '    ' .. line)
            table.insert(highlights, { line = #lines, group = utils.config.ui.highlights.diff_added })
          else
            table.insert(lines, '    ' .. line)
          end
        end
      end
    end
    table.insert(lines, '')
  end
  
  if #results.corrections > 0 then
    table.insert(lines, 'All Corrections:')
    table.insert(lines, string.rep('-', 30))
    for _, correction in ipairs(results.corrections) do
      for line in correction:gmatch('[^\r\n]+') do
        if line:match('^%-') then
          table.insert(lines, line)
          table.insert(highlights, { line = #lines, group = utils.config.ui.highlights.diff_removed })
        elseif line:match('^%+') then
          table.insert(lines, line)
          table.insert(highlights, { line = #lines, group = utils.config.ui.highlights.diff_added })
        else
          table.insert(lines, line)
        end
      end
      table.insert(lines, '')
    end
  end
  
  vim.api.nvim_buf_set_lines(M.results_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(M.results_buf, 'modifiable', false)
  
  local ns = vim.api.nvim_create_namespace('judge-results')
  vim.api.nvim_buf_clear_namespace(M.results_buf, ns, 0, -1)
  
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(M.results_buf, ns, hl.group, hl.line - 1, 0, -1)
  end
  
  if not M.results_win or not vim.api.nvim_win_is_valid(M.results_win) then
    M.create_results_window()
  end
end

function M.refresh_results()
  local judge = require('judge')
  judge.run_file()
end

function M.show_inline_results(results)
  local ns = vim.api.nvim_create_namespace('judge-inline')
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  
  local current_file = utils.get_current_file()
  local file_results = results.files[current_file]
  
  if not file_results then
    return
  end
  
  local virtual_text = {}
  if file_results.passed > 0 then
    table.insert(virtual_text, { string.format('✓ %d passed', file_results.passed), utils.config.ui.highlights.passed })
  end
  if file_results.failed > 0 then
    table.insert(virtual_text, { string.format('✗ %d failed', file_results.failed), utils.config.ui.highlights.failed })
  end
  
  if #virtual_text > 0 then
    vim.api.nvim_buf_set_extmark(0, ns, 0, 0, {
      virt_text = virtual_text,
      virt_text_pos = 'eol'
    })
  end
end

return M