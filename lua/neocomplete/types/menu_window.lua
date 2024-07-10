---@class neocomplete.menu_window
--- Creates a new instance of the menu window
---@field new fun(buf: integer, scrollbar_buf: integer): neocomplete.menu_window
---@field winnr? integer
--- Instance of the neocomplete config
---@field config neocomplete.config
---@field buf integer
--- Whether the window is currently opened above or below the cursor
---@field position? "above"|"below"
--- Data for the scrollbar of the window
---@field scrollbar {win: integer, buf: integer}
--- The maximum available height where the window is currently open
---@field max_height integer
--- Method to check whether the window is open or not
---@field is_open fun(self: neocomplete.menu_window): boolean
--- Method to check whether the scrollbar window is open or not
---@field scrollbar_is_open fun(self: neocomplete.menu_window): boolean
--- Adjust the window size to new entries. Modifies height and width while keeping position
---@field readjust fun(self: neocomplete.menu_window, entries: neocomplete.entry[], offset: integer): nil
--- Opens the window for the scrollbar
---@field open_scrollbar_win fun(self: neocomplete.menu_window, width: integer, height: integer, offset: integer): nil
--- Closes the window and the scrollbar window and resets fields
---@field close fun(self: neocomplete.menu_window): nil
--- Sets the scroll of the window
---@field set_scroll fun(self: neocomplete.menu_window, index: integer, direction: integer): nil
--- Opens a new main window
---@field open_win fun(self: neocomplete.menu_window, entries: neocomplete.entry[], offset: integer): nil