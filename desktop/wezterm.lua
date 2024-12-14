local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("Hasklug Nerd Font")
config.font_size = 14.0
config.enable_tab_bar = true
config.window_decorations = "RESIZE"
config.show_new_tab_button_in_tab_bar = false
config.warn_about_missing_glyphs = false
config.disable_default_key_bindings = false
config.leader = { key = "f", mods = "ALT", timeout_milliseconds = 1000 }
config.keys = {
  { key = "f", mods = "LEADER|ALT", action = act.SendKey({ key = "f", mods = "ALT" }) },
  { key = "C", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
  { key = "V", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },
  { key = "X", mods = "SHIFT|CTRL", action = act.ActivateCopyMode },
  { key = "v", mods = "ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "s", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "h", mods = "ALT|LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "ALT|LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "ALT|LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "ALT|LEADER", action = act.ActivatePaneDirection("Right") },
  { key = ";", mods = "ALT|LEADER", action = act.ActivateTabRelative(1) },
  { key = ",", mods = "ALT|LEADER", action = act.ActivateTabRelative(-1) },
  { key = "t", mods = "ALT|LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  {
    key = "w",
    mods = "ALT",
    action = act.ShowLauncherArgs({ flags = "WORKSPACES|FUZZY" }),
  },
  {
    key = "w",
    mods = "ALT|LEADER",
    action = act.PromptInputLine({
      description = "Rename current workspace",
      action = wezterm.action_callback(function(_, _, line) -- window, pane, line
        if line then
          wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
        end
      end),
    }),
  },
  { key = "/", mods = "ALT|LEADER", action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "P", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
  { key = "1", mods = "ALT", action = act.ActivateTab(0) },
  { key = "2", mods = "ALT", action = act.ActivateTab(1) },
  { key = "3", mods = "ALT", action = act.ActivateTab(2) },
  { key = "4", mods = "ALT", action = act.ActivateTab(3) },
  { key = "5", mods = "ALT", action = act.ActivateTab(4) },
  { key = "6", mods = "ALT", action = act.ActivateTab(5) },
  { key = "7", mods = "ALT", action = act.ActivateTab(6) },
  { key = "8", mods = "ALT", action = act.ActivateTab(7) },
  { key = "9", mods = "ALT", action = act.ActivateTab(8) },
  { key = "0", mods = "ALT", action = act.ActivateTab(9) },
  { key = ")", mods = "CTRL|SHIFT", action = act.ResetFontSize },
  { key = "{", mods = "CTRL|SHIFT", action = act.DecreaseFontSize },
  { key = "}", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
  { key = "L", mods = "CTRL", action = act.ShowDebugOverlay },
}
config.key_tables = {
  copy_mode = {
    { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    { key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
    { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
    { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
    { key = "V", mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
    { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
    {
      key = "y",
      mods = "NONE",
      action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
    },
  },

  search_mode = {
    { key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    { key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
    { key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
    { key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
    { key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
    { key = "PageUp", mods = "NONE", action = act.CopyMode("PriorMatchPage") },
    { key = "PageDown", mods = "NONE", action = act.CopyMode("NextMatchPage") },
    { key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },
    { key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
  },
}

local function append(to, list)
  for _, r in ipairs(list) do
    table.insert(to, r)
  end
  return to
end

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 32
wezterm.on(
  "format-tab-title",
  function(tab, _, _, _, hover, _) -- tab, tabs, panes, config, hover, max_width
    local title = tab.active_pane.title
    if tab.tab_title and #tab.tab_title > 0 then
      title = tab.tab_title
    end
    local blue = { Color = "#89b4fa" }
    local black = { Color = "#11111b" }
    local red = { Color = "#f38ba8" }
    local white = { Color = "#cdd6f4" }
    local grey = { Color = "#1e1e2e" }
    local orange = { Color = "#fab387" }

    local result = {}
    if tab.tab_index == 0 then
      append(result, {
        { Background = orange },
        { Foreground = black },
        { Text = wezterm.nerdfonts.pl_left_hard_divider },
        { Text = wezterm.nerdfonts.pl_left_soft_divider },
        { Text = " " },
        { Text = wezterm.mux.get_window(tab.window_id):get_workspace() },
        { Text = " " },
        { Text = wezterm.nerdfonts.pl_left_soft_divider },
        { Foreground = orange },
        { Background = black },
        { Text = wezterm.nerdfonts.pl_left_hard_divider },
      })
    end
    if tab.is_active then
      append(result, {
        { Background = blue },
        { Foreground = black },
        { Text = wezterm.nerdfonts.pl_left_hard_divider },
        { Foreground = black },
        { Text = (1 + tab.tab_index) .. wezterm.nerdfonts.pl_left_soft_divider },
        { Text = " " .. title .. " " },
        { Foreground = blue },
        { Background = black },
        { Text = wezterm.nerdfonts.pl_left_hard_divider },
      })
    elseif hover then
      append(result, {
        { Background = grey },
        { Foreground = black },
        { Text = wezterm.nerdfonts.pl_left_hard_divider },
        { Foreground = red },
        { Text = "" .. (1 + tab.tab_index) },
        { Foreground = orange },
        { Text = wezterm.nerdfonts.cod_chevron_right },
        { Foreground = red },
        { Text = " " .. title .. " " },
        { Background = black },
        { Foreground = grey },
        { Text = wezterm.nerdfonts.pl_left_hard_divider },
      })
    else
      append(result, {
        { Background = black },
        { Foreground = white },
        { Text = " " .. (1 + tab.tab_index) },
        { Foreground = orange },
        { Text = wezterm.nerdfonts.cod_chevron_right },
        { Foreground = white },
        { Text = " " .. title .. "  " },
        { Foreground = blue },
        { Background = black },
      })
    end
    return result
  end
)

wezterm.on("user-var-changed", function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}
  if name == "ZEN_MODE" then
    local incremental = value:find("+")
    local number_value = tonumber(value)
    if incremental ~= nil then
      while number_value > 0 do
        window:perform_action(wezterm.action.IncreaseFontSize, pane)
        number_value = number_value - 1
      end
      overrides.enable_tab_bar = false
    elseif number_value < 0 then
      window:perform_action(wezterm.action.ResetFontSize, pane)
      overrides.font_size = nil
      overrides.enable_tab_bar = config.enable_tab_bar
    else
      overrides.font_size = number_value
      overrides.enable_tab_bar = false
    end
  end
  window:set_config_overrides(overrides)
end)

return config
