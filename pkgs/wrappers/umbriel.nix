{
  flake.wrappers.umbriel =
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        wlib.modules.default
        wlib.modules.constructFiles
      ];

      config.package = pkgs.umbriel;

      config.constructFiles."appearance.toml" = {
        relPath = "umbriel/appearance.toml";
        content = ''
          # ==============================================================================
          # Appearance
          # Blur uses a smaller radius than the built-in default.
          # https://docs.noctalia.dev/umbriel/appearance/
          # [appearance.blur]
          # radius = 3


          [appearance.blur]
          enabled = true
          optimized = true
          passes = 3
          radius = 5
          noise = 0.02
          brightness = 0.9
          contrast = 0.9
          saturation = 1.1

          # Choose the background color shown if the lock screen takes too long to appear.
          # [colors]
          # backdrop = "#000000FF"
        '';
      };

      config.constructFiles."config.toml" = {
        relPath = "umbriel/config.toml";
        content = ''
          # Umbriel starting configuration
          #
          # Copy this file to ~/.config/umbriel/config.toml. Most changes apply when the
          # file is saved. Check edits with `umbriel validate`.
          #
          # Complete reference: https://docs.noctalia.dev/umbriel/
          #
          # Commented settings below are examples, not built-in defaults.

          # ==============================================================================
          # Includes

          # Optional split configuration
          # https://docs.noctalia.dev/umbriel/configuration/#include
          [include]
          files = [
            "appearance.toml",
            "general.toml",
            "input.toml",
            "keybinds.toml",
            "layout.toml",
            "outputs.toml",
            "overview.toml",
            "rules.toml",
          ]

          [include.optional]
          files = []
        '';
      };

      config.constructFiles."general.toml" = {
        relPath = "umbriel/general.toml";
        content = ''
          # ==============================================================================
          # General

          # Optional session examples. XWayland support is enabled by default.
          # https://docs.noctalia.dev/umbriel/configuration/#general
          # [general]
          # autostart = ["noctalia", "kitty"]
          # xwayland = false
        '';
      };

      config.constructFiles."input.toml" = {
        relPath = "umbriel/input.toml";
        content = ''
          # ==============================================================================
          # Input
          # Enable NumLock when a physical keyboard connects.
          # https://docs.noctalia.dev/umbriel/input/
          [input.keyboard]
          numlock_toggle = true

          # Focus can follow the pointer across tiled, floating, and pinned windows.
          # [input.focus]
          # follows_mouse = true
        '';
      };

      config.constructFiles."keybinds.toml" = {
        relPath = "umbriel/keybinds.toml";
        content = ''
          # ==============================================================================
          # Keybinds
          # Defining this table replaces the built-in bind set, so every active bind that
          # should remain available is listed here.
          # Syntax: https://docs.noctalia.dev/umbriel/keybinds/
          # Actions: https://docs.noctalia.dev/umbriel/actions/
          [keybinds]

          # Applications and session
          "Mod+Slash" = "cheatsheet-toggle"
          # "Mod+Return" = { action = "spawn:kitty", repeat = false }
          "Mod+T" = { action = "spawn:kitty", repeat = false }
          # "Mod" = "spawn:noctalia msg panel-toggle launcher"
          "Mod+D" = { action = "spawn:fuzzel", repeat = false }
          "Mod+Q" = { action = "window-close", repeat = false }
          "Mod+Escape" = "session-quit"
          "Mod+Shift+Escape" = { action = "shortcuts-inhibit-toggle", allow_when_inhibited = true, repeat = false }

          # Focus and movement
          "Mod+Left" = "window-focus-left"
          "Mod+Down" = "window-focus-down"
          "Mod+Up" = "window-focus-up"
          "Mod+Right" = "window-focus-right"
          "Mod+H" = "window-focus-left"
          "Mod+J" = "window-focus-down"
          "Mod+K" = "window-focus-up"
          "Mod+L" = "window-focus-right"
          "Mod+F1" = "window-focus-next"
          "Mod+Shift+Left" = "column-move-left"
          "Mod+Shift+Down" = "window-move-down"
          "Mod+Shift+Up" = "window-move-up"
          "Mod+Shift+Right" = "column-move-right"

          # Window state and layout
          # "Mod+T" = { action = "window-toggle-floating", repeat = false }
          "Mod+V" = { action = "window-toggle-floating", repeat = false }
          "Mod+Shift+T" = { action = "window-focus-switch-floating", repeat = false }
          "Mod+P" = { action = "window-toggle-pinned", repeat = false }
          "Mod+M" = { action = "window-toggle-maximize-to-edges", repeat = false }
          # "Mod+F" = { action = "window-toggle-fullscreen", repeat = false }
          # "Mod+Ctrl+F" = { action = "window-toggle-maximize", repeat = false }
          "Mod+Ctrl+F" = { action = "window-toggle-fullscreen", repeat = false }
          "Mod+F" = { action = "window-toggle-maximize", repeat = false }
          "Mod+R" = "window-cycle-primary-extent"
          "Mod+Shift+R" = "window-cycle-primary-extent-back"
          "Mod+Comma" = "window-consume-left"
          "Mod+Period" = "window-consume-right"
          "Mod+WheelUp" = "window-focus-left"
          "Mod+WheelDown" = "window-focus-right"
          "Mod+O" = { action = "overview-toggle", repeat = false }

          # Workspaces
          "Mod+1" = "workspace-switch:1"
          "Mod+2" = "workspace-switch:2"
          "Mod+3" = "workspace-switch:3"
          "Mod+4" = "workspace-switch:4"
          "Mod+5" = "workspace-switch:5"
          "Mod+6" = "workspace-switch:6"
          "Mod+7" = "workspace-switch:7"
          "Mod+8" = "workspace-switch:8"
          "Mod+9" = "workspace-switch:9"
          "Mod+Shift+1" = "window-move-to-workspace:1"
          "Mod+Shift+2" = "window-move-to-workspace:2"
          "Mod+Shift+3" = "window-move-to-workspace:3"
          "Mod+Shift+4" = "window-move-to-workspace:4"
          "Mod+Shift+5" = "window-move-to-workspace:5"
          "Mod+Shift+6" = "window-move-to-workspace:6"
          "Mod+Shift+7" = "window-move-to-workspace:7"
          "Mod+Shift+8" = "window-move-to-workspace:8"
          "Mod+Shift+9" = "window-move-to-workspace:9"

          # Scratchpad
          "Mod+Shift+Space" = { action = "window-move-to-scratchpad", repeat = false }
          "Mod+Space" = "scratchpad-toggle"
          "Mod+Ctrl+Space" = { action = "window-restore-from-scratchpad", repeat = false }
          "Mod+Tab" = "scratchpad-focus-next"

          # screenshot
          # 区域截图
          "Print" = "spawn:noctalia msg screenshot-region"

          # 当前显示器截图
          "Ctrl+Print" = "spawn:noctalia msg screenshot-fullscreen"

          # 截图并进入 Noctalia 标注器
          "Super+Print" = "spawn:noctalia msg screenshot-annotate"
        '';
      };

      config.constructFiles."layout.toml" = {
        relPath = "umbriel/layout.toml";
        content = ''
          # ==============================================================================
          # Layout
          # New scrolling-layout windows start at half the output width. Without this
          # setting, each application chooses its starting width. Stacked columns retain
          # their most recently focused row when focus leaves and later returns.
          # https://docs.noctalia.dev/umbriel/layout/
          [layout]
          extent_presets = [0.333, 0.5, 0.667]

          [layout.scrolling]
          default_extent_fraction = 0.5
        '';
      };

      config.constructFiles."outputs.toml" = {
        relPath = "umbriel/outputs.toml";
        content = ''
          # ==============================================================================
          # Outputs

          # Outputs are machine-specific. Run `umbriel outputs` to find names and modes.
          # https://docs.noctalia.dev/umbriel/outputs/

          # 笔记本内置显示器 (Chimei Innolux 2.5K 165Hz)
          [output.eDP-1]
          enabled = false
          # mode = "2560x1440@144"
          mode = "2560x1440@165.003"
          position = [0, 0]
          scale = 1.5
          vrr = "fullscreen"
          hdr = "auto"

          # 外接 KTC 显示器 (1080p 120Hz)
          [output.HDMI-A-1]
          enabled = true
          mode = "1920x1080@120"
          position = [0, 0]
          scale = 1.0
          vrr = "fullscreen"
          hdr = "auto"

          # KTC Technology Group H27T22S-3 Pro (2K 144Hz)
          # [output.HDMI-A-1]
          # enabled = true
          # mode = "2560x1440@144.002"
          # position = [0, 0]
          # scale = 1.25
          # vrr = "fullscreen"
          # hdr = "auto"
        '';
      };

      config.constructFiles."overview.toml" = {
        relPath = "umbriel/overview.toml";
        content = ''
          # ==============================================================================
          # Overview
          # Built-in overview and animation values are used. The top-left hot corner opens
          # the overview after a short delay.
          # Overview: https://docs.noctalia.dev/umbriel/workspaces-overview/
          # Animation: https://docs.noctalia.dev/umbriel/animation/
          [hot_corners.top_left]
          enabled = true
          delay_ms = 500
          action = "overview-open"
        '';
      };

      config.constructFiles."rules.toml" = {
        relPath = "umbriel/rules.toml";
        content = ''
          # ==============================================================================
          # Window rules
          # Rules combine in order, with later values overriding earlier ones.
          # https://docs.noctalia.dev/umbriel/window-rules/

          # Blur windows using the non-optimized path so translucent windows include
          # overlapping windows behind them.
          [[window_rule]]
          blur = true
          blur_optimized = false

          [[window_rule]]
          match.app_id = "^dev.noctalia.Noctalia$"
          default_floating = true
          default_floating_size_px = { width = 1020, height = 900 }

          [[window_rule]]
          match.app_id = "^dev.noctalia.UmbrielSharePicker$"
          default_floating = true
          default_floating_size_px = { width = 800, height = 600 }

          [[window_rule]]
          match.title = "^(Picture-in-Picture|Picture in picture)$"
          default_floating = true
          default_maximize = false
          default_position = { x = 20, y = 20, anchor = "bottom_right" }

          [[window_rule]]
          match.title = "^notificationtoasts_.+_desktop"
          default_position = { x = 0, y = 0, anchor = "bottom_right" }
          default_focused = false
          default_pinned = true

          # Give scratchpad windows their own border colors.
          # [[window_rule]]
          # match.is_scratchpad = true
          # border_color_focused = "#E5C07BFF"
          # border_color_unfocused = "#5C4A2AFF"

          # Leave an application that draws its own corners and shadow undecorated.
          # [[window_rule]]
          # match.app_id = "^org[.]gnome[.]TextEditor$"
          # border_width = 0
          # corner_radius = 0
          # shadow = false

          # ============================================================
          # 全局：所有窗口半透明，默认不模糊
          # ============================================================

          [[window_rule]]
          opacity = 0.85
          blur = false
          corner_radius = 12


          # ============================================================
          # 聚焦窗口：保持半透明 + 背景毛玻璃
          # ============================================================

          [[window_rule]]
          match.is_focused = true
          opacity = 0.85
          blur = true


          # ============================================================
          # 特定应用：更透明
          # ============================================================

          [[window_rule]]
          match.app_id = "^(code|codium|antigravity|kitty|Alacritty|dev[.]zed[.]Zed)$"
          opacity = 0.82


          # ============================================================
          # Noctalia layer：不参与窗口毛玻璃
          # ============================================================

          [[layer_rule]]
          match.namespace = "^noctalia.*"
          blur = false

          # ==============================================================================
          # Layer rules
          # https://docs.noctalia.dev/umbriel/layer-rules/
          [[layer_rule]]
          match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$"
          blur = true
          blur_ignore_alpha = 0.5
          blur_popups = true
          blur_optimized = false
        '';
      };

      config.runShell = [
        ''mkdir -p "$HOME/.config/umbriel"''
        ''cp -f ${config.constructFiles."appearance.toml".path} "$HOME/.config/umbriel/appearance.toml"''
        ''mkdir -p "$HOME/.config/umbriel"''
        ''cp -f ${config.constructFiles."config.toml".path} "$HOME/.config/umbriel/config.toml"''
        ''mkdir -p "$HOME/.config/umbriel"''
        ''cp -f ${config.constructFiles."general.toml".path} "$HOME/.config/umbriel/general.toml"''
        ''mkdir -p "$HOME/.config/umbriel"''
        ''cp -f ${config.constructFiles."input.toml".path} "$HOME/.config/umbriel/input.toml"''
        ''mkdir -p "$HOME/.config/umbriel"''
        ''cp -f ${config.constructFiles."keybinds.toml".path} "$HOME/.config/umbriel/keybinds.toml"''
        ''mkdir -p "$HOME/.config/umbriel"''
        ''cp -f ${config.constructFiles."layout.toml".path} "$HOME/.config/umbriel/layout.toml"''
        ''mkdir -p "$HOME/.config/umbriel"''
        ''cp -f ${config.constructFiles."outputs.toml".path} "$HOME/.config/umbriel/outputs.toml"''
        ''mkdir -p "$HOME/.config/umbriel"''
        ''cp -f ${config.constructFiles."overview.toml".path} "$HOME/.config/umbriel/overview.toml"''
        ''mkdir -p "$HOME/.config/umbriel"''
        ''cp -f ${config.constructFiles."rules.toml".path} "$HOME/.config/umbriel/rules.toml"''
      ];
      config.passthru.providedSessions = pkgs.umbriel.passthru.providedSessions;
    };

  perSystem = { pkgs, ... }: {
    wrappers.control_type = "exclude";
  };

}
