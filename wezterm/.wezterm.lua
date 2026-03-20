local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

-- デフォルトをWSL2に変更
config.default_prog = { 'wsl.exe', '~', '--cd', '~' }

config.launch_menu = {
  { label = 'CMD', args = { 'cmd.exe' } },
  { label = 'PowerShell', args = { 'powershell.exe' } },
  { label = 'Ubuntu (WSL)', args = { 'wsl.exe', '-d', 'Ubuntu' } },
}

-- Appearance
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font('MesloLGS NF')
config.font_size = 12.0
config.window_decorations = 'RESIZE'
config.use_fancy_tab_bar = true
config.tab_max_width = 25
config.scrollback_lines = 10000

-- Transparency and blur
config.window_background_opacity = 0.85
config.win32_system_backdrop = 'Acrylic'

-- Cursor (retro neon green) and CRT-like foreground
config.default_cursor_style = 'SteadyBlock'
config.colors = {
  foreground = '#c8d2e0',
  cursor_bg = '#00ff41',
  cursor_fg = '#1a1b26',
  cursor_border = '#00ff41',
}

-- Bell / Notifications
config.audible_bell = 'SystemBeep'
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 150,
  target = 'CursorColor',
}

-- Leader key
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }

-- Keybindings
config.keys = {
  -- Tab operations
  { key = 'h', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = 'l', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentTab { confirm = true } },
  { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
  { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
  { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
  { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
  { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },
  { key = '6', mods = 'LEADER', action = act.ActivateTab(5) },
  { key = '7', mods = 'LEADER', action = act.ActivateTab(6) },
  { key = '8', mods = 'LEADER', action = act.ActivateTab(7) },
  { key = '9', mods = 'LEADER', action = act.ActivateTab(8) },

  -- Scroll (half page)
  { key = 'u', mods = 'CTRL', action = act.ScrollByPage(-0.5) },
  { key = 'd', mods = 'CTRL', action = act.ScrollByPage(0.5) },

  -- Copy mode
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },

  -- Font size
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },

  -- Search
  { key = '/', mods = 'LEADER', action = act.Search { CaseInSensitiveString = '' } },

  -- Quick select
  { key = 's', mods = 'LEADER', action = act.QuickSelect },
}

-- Quick select custom patterns (appended to defaults)
config.quick_select_patterns = {
  '[0-9a-f]{7,40}',                                  -- git hashes
  '\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}',      -- IPv4 addresses
}

return config
