local care_sources = {}
local Entry = require("care.entry")

---@type care.internal_source[]
care_sources.sources = {}

---@param completion_source care.source
function care_sources.register_source(completion_source)
    local source = require("care.source").new(completion_source)
    table.insert(care_sources.sources, source)
end

---@return care.internal_source[]
function care_sources.get_sources()
    return vim.deepcopy(care_sources.sources)
end

function care_sources.update_configs()
    local source_configs = require("care.config").options.sources or {}
    for _, source in ipairs(care_sources.sources) do
        source.config = source_configs[source.source.name] or {}
    end
end

---@param context care.context
---@param source care.internal_source
---@param callback fun(items: care.entry[], is_incomplete?: boolean)
function care_sources.complete(context, source, callback)
    local last_char = context.line_before_cursor:sub(-1)
    ---@type lsp.CompletionContext
    local completion_context
    if context.reason == 1 then
        if vim.tbl_contains(source:get_trigger_characters(), last_char) then
            completion_context = {
                triggerKind = 2,
                triggerCharacter = last_char,
            }
        elseif (context.cursor.col - source:get_offset(context)) < 1 then
            if context.line_before_cursor:match("%s+$") or context.line_before_cursor == "" then
                callback({})
            else
                callback(source.entries)
            end
            return
        elseif not source.entries or #source.entries == 0 then
            completion_context = {
                triggerKind = 2,
                triggerCharacter = last_char,
            }
        elseif not source.incomplete then
            local source_offset = source:get_offset(context)
            if source_offset == -1 then
                callback(source.entries)
                return
            end

            local prefix = context.line:sub(source_offset + 1, context.cursor.col)

            if #prefix == 0 then
                callback(source.entries)
                return
            elseif prefix:match("^%s+$") then
                callback({})
                return
            end

            callback(require("care.matcher").match(source.entries, prefix))
            return
        else
            completion_context = {
                triggerKind = 3,
            }
        end
    elseif context.reason == 3 then
        local char_before = string.match(context.line_before_cursor, "(.)%s*$")
        if vim.tbl_contains(source:get_trigger_characters(), char_before) then
            completion_context = {
                triggerKind = 2,
                triggerCharacter = char_before,
            }
        else
            callback({})
            return
        end
    else
        completion_context = {
            triggerKind = 1,
        }
    end
    if source.incomplete and context.reason ~= 3 then
        completion_context = {
            triggerKind = 3,
        }
    end
    source.source.complete(
        { completion_context = completion_context, context = context },
        function(items, is_incomplete)
            items = vim.iter(items or {})
                :map(function(item)
                    return Entry.new(item, source, context)
                end)
                :totable()
            local source_offset = source:get_offset(context)
            if source_offset == -1 then
                callback(source.entries)
                return
            end

            local prefix = context.line:sub(source_offset + 1, context.cursor.col)
            if #prefix == 0 then
                callback(items, is_incomplete)
                return
            elseif prefix:match("^%s+$") then
                callback({}, is_incomplete)
                return
            end
            callback(require("care.matcher").match(items, prefix), is_incomplete)
        end
    )
end

return care_sources
