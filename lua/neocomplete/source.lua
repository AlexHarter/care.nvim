---@type neocomplete.internal_source
---@diagnostic disable-next-line: missing-fields
local source = {}

function source.new(completion_source)
    ---@type neocomplete.internal_source
    local self = setmetatable({}, { __index = source })
    self.source = completion_source
    self.entries = {}
    return self
end

function source.get_offset(self, context)
    if not context then
        return 0
    end
    -- TODO: allow sources configuring their keyword pattern
    local line = vim.api.nvim_get_current_line()
    local line_to_cursor = line:sub(1, context.cursor.col)
    local keyword_pattern = require("neocomplete.config").options.keyword_pattern
    if self.source.keyword_pattern then
        keyword_pattern = self.source.keyword_pattern
    end
    if self.source.get_keyword_pattern then
        keyword_pattern = self.source:get_keyword_pattern()
    end
    -- Can add $ to keyword pattern because we just match on line to cursor
    local word_boundary = vim.fn.match(line_to_cursor, keyword_pattern .. "$")
    if word_boundary == -1 then
        return 0
    end

    local prefix = line:sub(word_boundary + 1, context.cursor.col)
    return #prefix
end

return source