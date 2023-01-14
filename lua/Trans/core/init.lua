local M = {}
local conf = require('Trans').conf
local api = require('Trans.api')
local win = require('Trans.core.window')
local handler = require('Trans.core.handler')
local c = require('Trans.core.content')


local function get_select()
    local s_start = vim.fn.getpos("v")
    local s_end = vim.fn.getpos(".")
    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    lines[1] = string.sub(lines[1], s_start[3], -1)
    if n_lines == 1 then
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end
    return table.concat(lines, '')
end

M.translate = function(method, view)
    method = method or vim.api.nvim_get_mode().mode
    view = view or conf.view[method]
    local word
    if method == 'v' then
        ---@diagnostic disable-next-line: param-type-mismatch
        word = vim.fn.input('请输入您要查询的单词: ') -- TODO Use Telescope with fuzzy finder
    elseif method == 'n' then
        word = vim.fn.expand('<cword>')
    elseif method == 'input' then
        word = get_select()
    elseif method == 'last' then
        return win.show()
    end

    win.init(view)
    local result = api.query('offline', word)
    local content = c:new(win.width)
    local hd = handler[view]

    if result then
        for i = 1, #conf.order do
            hd[conf.order[i]](result, content)
        end

    else
        hd.failed(content)
    end
    win.draw(content)
end


return M
