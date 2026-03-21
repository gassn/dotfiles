local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action
local workspace_presets = { 'default', 'project-a', 'project-b' }

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
config.use_fancy_tab_bar = false
config.tab_max_width = 25
config.scrollback_lines = 10000
config.status_update_interval = 1000

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
config.leader = { key = 'Space', mods = 'CTRL|SHIFT', timeout_milliseconds = 1000 }

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

  -- Workspace selector
  { key = 'w', mods = 'LEADER', action = wezterm.action_callback(function(window, pane)
    local workspaces = {}
    local seen = {}

    -- Add presets first
    for _, name in ipairs(workspace_presets) do
      table.insert(workspaces, { id = name, label = name })
      seen[name] = true
    end

    -- Add active workspaces not in presets
    local active = wezterm.mux.get_workspace_names()
    table.sort(active)
    for _, name in ipairs(active) do
      if not seen[name] then
        table.insert(workspaces, { id = name, label = name })
      end
    end

    window:perform_action(act.InputSelector {
      title = 'Switch Workspace',
      choices = workspaces,
      fuzzy = true,
      action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
        if id then
          inner_window:perform_action(act.SwitchToWorkspace { name = id }, inner_pane)
        end
      end),
    }, pane)
  end) },

  -- New workspace
  { key = 'w', mods = 'LEADER|SHIFT', action = act.PromptInputLine {
    description = 'Enter new workspace name',
    action = wezterm.action_callback(function(window, pane, line)
      if line and line ~= '' then
        window:perform_action(act.SwitchToWorkspace { name = line }, pane)
      end
    end),
  } },
}

-- Quick select custom patterns (appended to defaults)
config.quick_select_patterns = {
  '[0-9a-f]{7,40}',                                  -- git hashes
  '\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}',      -- IPv4 addresses
}

-- Status bar
wezterm.on('update-right-status', function(window, pane)
  -- Workspace
  local workspace = window:active_workspace()

  -- User@Host
  local user = os.getenv('USERNAME') or os.getenv('USER') or 'unknown'
  local hostname = wezterm.hostname()

  -- Battery
  local battery_text = ''
  local battery_info = wezterm.battery_info()
  if #battery_info > 0 then
    local charge = battery_info[1].state_of_charge
    local battery_icon
    if charge > 0.75 then
      battery_icon = wezterm.nerdfonts.fa_battery_full
    elseif charge > 0.50 then
      battery_icon = wezterm.nerdfonts.fa_battery_three_quarters
    elseif charge > 0.25 then
      battery_icon = wezterm.nerdfonts.fa_battery_half
    elseif charge > 0.10 then
      battery_icon = wezterm.nerdfonts.fa_battery_quarter
    else
      battery_icon = wezterm.nerdfonts.fa_battery_empty
    end
    battery_text = battery_icon .. ' ' .. string.format('%.0f%%', charge * 100)
  end

  -- Date/Time
  local date_time = wezterm.strftime('%Y-%m-%d %H:%M')

  -- Colors
  local bg_dark = '#1a1b26'
  local bg_light = '#24283b'
  local fg = '#a9b1d6'
  local sep_fg = '#565f89'

  -- Build segments
  local segments = {}

  -- Workspace segment
  table.insert(segments, { Foreground = { Color = fg } })
  table.insert(segments, { Background = { Color = bg_dark } })
  table.insert(segments, { Text = ' ' .. wezterm.nerdfonts.cod_window .. ' ' .. workspace .. ' ' })

  -- Separator
  table.insert(segments, { Foreground = { Color = sep_fg } })
  table.insert(segments, { Background = { Color = bg_light } })
  table.insert(segments, { Text = '' })

  -- User@Host segment
  table.insert(segments, { Foreground = { Color = fg } })
  table.insert(segments, { Background = { Color = bg_light } })
  table.insert(segments, { Text = ' ' .. wezterm.nerdfonts.fa_user .. ' ' .. user .. '@' .. hostname .. ' ' })

  -- Battery segment (only if battery exists)
  if battery_text ~= '' then
    table.insert(segments, { Foreground = { Color = sep_fg } })
    table.insert(segments, { Background = { Color = bg_dark } })
    table.insert(segments, { Text = '' })

    table.insert(segments, { Foreground = { Color = fg } })
    table.insert(segments, { Background = { Color = bg_dark } })
    table.insert(segments, { Text = ' ' .. battery_text .. ' ' })
  end

  -- Separator
  table.insert(segments, { Foreground = { Color = sep_fg } })
  table.insert(segments, { Background = { Color = bg_light } })
  table.insert(segments, { Text = '' })

  -- Date/Time segment
  table.insert(segments, { Foreground = { Color = fg } })
  table.insert(segments, { Background = { Color = bg_light } })
  table.insert(segments, { Text = ' ' .. wezterm.nerdfonts.fa_clock_o .. ' ' .. date_time .. ' ' })

  window:set_right_status(wezterm.format(segments))
end)

return config
