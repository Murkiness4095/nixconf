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
          size = 14.0;
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
            background = "#111418";
            foreground = "#e1e2e8";
          };

          selection = {
            text = "#e1e2e8";
            background = "#1a4975";
          };

          cursor = {
            text = "#111418";
            cursor = "#a0cafd";
          };

          normal = {
            black = "#111418";
            red = "#ff729c";
            green = "#7efd8f";
            yellow = "#fff772";
            blue = "#86b6f0";
            magenta = "#264975";
            cyan = "#a0cafd";
            white = "#eff6ff";
          };

          bright = {
            black = "#989da4";
            red = "#ff9fbb";
            green = "#a5ffb1";
            yellow = "#fffaa5";
            blue = "#afd3ff";
            magenta = "#bddbff";
            cyan = "#d4e7ff";
            white = "#f8fbff";
          };
        };
      };
    };
  perSystem = { pkgs, ... }: {
    wrappers.control_type = "exclude";
  };
}
