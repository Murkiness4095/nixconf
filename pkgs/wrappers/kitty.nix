{ config, lib, ... }:
{
  flake.wrappers.kitty =
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    let
      # base16 palette from vimjoyer's theme.nix
      theme = {
        base00 = "#242424";
        base01 = "#3c3836";
        base02 = "#504945";
        base03 = "#665c54";
        base04 = "#bdae93";
        base05 = "#d5c4a1";
        base06 = "#ebdbb2";
        base07 = "#fbf1c7";
        base08 = "#fb4934";
        base09 = "#fe8019";
        base0A = "#fabd2f";
        base0B = "#b8bb26";
        base0C = "#8ec07c";
        base0D = "#7daea3";
        base0E = "#e089a1";
        base0F = "#f28534";
      };
    in
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

        background = theme.base00;
        foreground = theme.base07;

        cursor = theme.base07;

        selection_foreground = theme.base02;
        selection_background = theme.base01;

        active_tab_foreground = theme.base0B;
        active_tab_background = theme.base03;
        inactive_tab_background = theme.base01;

        color0 = theme.base00;
        color8 = theme.base02;
        color1 = theme.base08;
        color9 = theme.base08;
        color2 = theme.base0B;
        color10 = theme.base0B;
        color3 = theme.base0A;
        color11 = theme.base0A;
        color4 = theme.base0D;
        color12 = theme.base0D;
        color5 = theme.base0E;
        color13 = theme.base0E;
        color6 = theme.base0C;
        color14 = theme.base0C;
        color7 = theme.base03;
        color15 = theme.base03;
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
