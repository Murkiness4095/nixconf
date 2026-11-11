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
            background = "#242424";
            foreground = "#fbf1c7";
          };

          selection = {
            text = "#504945";
            background = "#3c3836";
          };

          cursor = {
            text = "#242424";
            cursor = "#fbf1c7";
          };

          normal = {
            black = "#242424";
            red = "#fb4934";
            green = "#b8bb26";
            yellow = "#fabd2f";
            blue = "#7daea3";
            magenta = "#e089a1";
            cyan = "#8ec07c";
            white = "#665c54";
          };

          bright = {
            black = "#3c3836";
            red = "#fb4934";
            green = "#b8bb26";
            yellow = "#fabd2f";
            blue = "#7daea3";
            magenta = "#e089a1";
            cyan = "#8ec07c";
            white = "#665c54";
          };
        };
      };
    };
  perSystem = { pkgs, ... }: {
    wrappers.control_type = "exclude";
  };
}
