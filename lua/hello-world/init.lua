local M = {}

local function get_position()
  local cursor = vim.api.nvim_win_get_cursor(0)
  return {
    bufnr = vim.api.nvim_get_current_buf(),
    row = cursor[1] - 1,
    col = cursor[2]
  }
end

function M.currentLine()
  local pos = get_position()

  print('current row: ', pos.row)
  print('current col: ', pos.col)

  local lines = vim.api.nvim_buf_get_lines(pos.bufnr, pos.row, pos.row + 1, false) -- expecting one line
  print('current line: ', lines[1])
end

---@param text string
---@param pad string
---@param count integer
---@return string
local function left_pad(text, pad, count)
  local a = string.rep(pad, count / string.len(pad))
  return string.format("%s%s", a, text)
end

---@param bufnr integer
---@param line integer
---@return integer
local function get_line_length(bufnr, line)
  local l = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]
  if l == nil then
    return -1
  end

  return string.len(l)
end

---@param bufnr integer
---@param line integer
---@param start integer
---@param end_ integer
---@param text string
local function writeLine(bufnr, line, start, end_, text)
  local l = get_line_length(bufnr, line)

  if l < 0 then
    -- there is no line, create one
    text = left_pad(text, ' ', start)
    vim.api.nvim_buf_set_lines(bufnr, line, line + 1, false, { text })
    return
  end

  if l < start then
    text = left_pad(text, ' ', start - l)
    start = l
  end
  end_ = math.max(math.min(end_, l), start)
  vim.api.nvim_buf_set_text(bufnr, line, start, line, end_, { text, })
end

---Draws a rectangle with given width and height in the current open window cursor
---
---The minimal height is 2 (otherwise we're drawing a horizontal line)
---The minimal width is 2 (otherwise we're drawing a vertical line)
---
---@param height integer
---@param width integer
---
function M.createRect(height, width)
  if height < 2 then error('height must be greater than or equal to 2') end
  if width < 2 then error('height must be greater than or equal to 2') end

  if vim.bo.filetype ~= 'markdown' then
    print("I create rects only in markdown")
    return
  end

  local p = get_position()
  print('row: ', p.row)


  height = math.floor(height / 2)
  width = math.floor(width / 2)

  local up = p.row - height
  local down = p.row + height
  local left = p.col - width
  local right = p.col + width

  if left < 0 then
    -- shift right
    right = right - left
    p.col = p.col - left
    left = 0
  end

  local line = string.format("+%s+", string.rep('-', right - left - 2))
  local middle = string.format("|%s|", string.rep(' ', right - left - 2))

  writeLine(p.bufnr, up, left, right, line)
  for mid = up + 1, down - 1 do
    writeLine(p.bufnr, mid, left, right, middle)
  end
  writeLine(p.bufnr, down, left, right, line)

  print('row (after): ', p.row)
  vim.fn.cursor({ p.row + 1, p.col })
end

return M
