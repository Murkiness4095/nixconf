{ config, lib, ... }:
let
  t = config.flake.theme;
in
{
  flake.wrappers.kitty =
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.kitty ];

      config.package = pkgs.kitty;

      config.settings = {
        enable_audio_bell = "no";

        font_size = 15;
        font_family = "ComicShannsMono Nerd Font";

        cursor_text_color = "background";

        allow_remote_control = "yes";
        shell_integration = "enabled";

        cursor_trail = 3;

        background = t.base00;
        foreground = t.base05;

        cursor = t.base05;

        selection_foreground = t.base02;
        selection_background = t.base01;

        active_tab_foreground = t.base0B;
        active_tab_background = t.base03;
        inactive_tab_background = t.base01;

        color0 = t.base00;
        color8 = t.base02;
        color1 = t.base08;
        color9 = t.base08;
        color2 = t.base0B;
        color10 = t.base0B;
        color3 = t.base0A;
        color11 = t.base0A;
        color4 = t.base0D;
        color12 = t.base0D;
        color5 = t.base0E;
        color13 = t.base0E;
        color6 = t.base0C;
        color14 = t.base0C;
        color7 = t.base03;
        color15 = t.base03;
      };

      config.keybindings = {
        "alt+1" = "goto_tab 1";
        "alt+2" = "goto_tab 2";
        "alt+3" = "goto_tab 3";
        "alt+4" = "goto_tab 4";
        "alt+5" = "goto_tab 5";
        "alt+6" = "goto_tab 6";
        "alt+7" = "goto_tab 7";
        "alt+8" = "goto_tab 8";
        "alt+9" = "goto_tab 9";
        "ctrl+shift+w" = "close_tab";
        "ctrl+t" = "new_tab_with_cwd";
        "ctrl+shift+t" = "new_tab";
      };
    };
}
