{
  flake.wrappers.fastfetch =
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

      config.package = pkgs.fastfetch;

      config.constructFiles.generatedConfig = {
        content = ''
          {
            "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json",
            "display": {
              "color": {
                "output": "#cbc4cf",
                "title": "#cbc4cf",
              },
              "separator": " ",
            },
            "logo": {
              "height": 22,
              "padding": {
                "left": 2,
                "right": 2,
                "top": 2,
              },
              "source": "${../../assets/logo/nixos.png}",
              "type": "auto",
            },
            "modules": [
              "break",
              {
                "key": "OS",
                "keyColor": "#d3bbfd",
                "type": "os",
              },
              {
                "key": " ├   KER ",
                "keyColor": "#d3bbfd",
                "type": "kernel",
              },
              {
                "format": "{all}",
                "key": " ├   PAK ",
                "keyColor": "#d3bbfd",
                "type": "packages",
              },
              {
                "key": " └   USR ",
                "keyColor": "#d3bbfd",
                "type": "title",
              },
              "break",
              "break",
              {
                "key": "WM",
                "keyColor": "#f1b7c5",
                "type": "wm",
              },
              {
                "key": " ├ 󱈹  DES ",
                "keyColor": "#f1b7c5",
                "type": "de",
              },
              {
                "key": " ├   SHE ",
                "keyColor": "#f1b7c5",
                "type": "shell",
              },
              {
                "key": " ├   TER ",
                "keyColor": "#f1b7c5",
                "type": "terminal",
              },
              {
                "key": " └   TFO ",
                "keyColor": "#f1b7c5",
                "type": "terminalfont",
              },
              "break",
              "break",
              {
                "key": "PC ",
                "keyColor": "#eadef8",
                "type": "host",
              },
              {
                "key": " ├   CPU ",
                "keyColor": "#eadef8",
                "type": "cpu",
              },
              {
                "key": " ├   MEM ",
                "keyColor": "#eadef8",
                "type": "memory",
              },
              {
                "format": "{1} {2}",
                "key": " ├ 󰢮  GPU ",
                "keyColor": "#eadef8",
                "type": "gpu",
              },
              {
                "format": "{name} {width}x{height}@{refresh-rate} ",
                "key": " ├   MON ",
                "keyColor": "#eadef8",
                "type": "display",
              },
              {
                "key": " └ 󰋊  DIS ",
                "keyColor": "#eadef8",
                "type": "disk",
              },
              "break",
              "break",
              "colors",
            ],
          }
        '';
        relPath = "fastfetch-config.jsonc";
      };

      config.runShell = [
        ''if [ -n "$KITTY_WINDOW_ID" ] || [ "$TERM_PROGRAM" = "kitty" ] || [ "$TERM_PROGRAM" = "WezTerm" ] || [ "$TERM_PROGRAM" = "ghostty" ]; then exec ${lib.getExe pkgs.fastfetch} --config ${config.constructFiles.generatedConfig.path} --logo-type auto; else exec ${lib.getExe pkgs.fastfetch} --config ${config.constructFiles.generatedConfig.path} --logo-type builtin --logo nixos; fi''
      ];
    };

  perSystem = { pkgs, ... }: {
    wrappers.control_type = "exclude";
  };
}
