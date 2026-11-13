{ config, ... }:
let
  t = config.flake.theme;
in
{
  flake.wrappers.alacritty =
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.alacritty ];

      config.package = pkgs.alacritty;

      config.settings = {
        window = {
          decorations = "None";
          dynamic_title = true;
          startup_mode = "Windowed";
        };

        font = {
          size = 15.0;
          normal = {
            family = "ComicShannsMono Nerd Font";
            style = "Regular";
          };
        };

        scrolling = {
          history = 10000;
        };

        terminal = {
          osc52 = "CopyPaste";
        };

        colors = {
          primary = {
            background = t.base00;
            foreground = t.base05;
          };

          selection = {
            text = t.base02;
            background = t.base01;
          };

          cursor = {
            text = t.base00;
            cursor = t.base0C;
          };

          normal = {
            black = t.base00;
            red = t.base08;
            green = t.base0B;
            yellow = t.base0A;
            blue = t.base0D;
            magenta = t.base0E;
            cyan = t.base0C;
            white = t.base03;
          };

          bright = {
            black = t.base01;
            red = t.base08;
            green = t.base0B;
            yellow = t.base0A;
            blue = t.base0D;
            magenta = t.base0E;
            cyan = t.base0C;
            white = t.base03;
          };
        };
      };
    };
  perSystem = { pkgs, ... }: {
    wrappers.control_type = "exclude";
  };
}
