{
  flake.wrappers.zed =
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

      config.package = pkgs.zed-editor;
      config.runtimePkgs = [ pkgs.nixfmt ];

      config.constructFiles.settings = {
        relPath = "zed/settings.json";
        content = ''
          {
            "extend_comment_on_newline": false,
            "cli_default_open_behavior": "new_window",
            "project_panel": { "dock": "left" },
            "assistant": {
              "default_model": "copilot_chat/claude-sonnet-4.5",
              "version": "2"
            },
            "features": {
              "edit_prediction_provider": "copilot"
            },
            "buffer_font_family": "ComicShannsMono Nerd Font",
            "buffer_font_fallbacks": [
              "LXGW WenKai Screen",
              "JetBrainsMono Nerd Font",
              "monospace"
            ],
            "buffer_font_size": 14,
            "ui_font_size": 15,
            "colorize_brackets": true,
            "autosave": "on_focus_change",
            "tab_size": 2,
            "format_on_save": "on",
            "tabs": {
              "activate_on_close": "history",
              "limit": 10
            },
            "languages": {
              "Nix": {
                "tab_size": 2,
                "format_on_save": "on",
                "language_servers": ["nil"],
                "formatter": {
                  "external": {
                    "command": "nixfmt"
                  }
                }
              }
            },
            "context_servers": {
              "nixos": {
                "command": "mcp-nixos",
                "args": []
              }
            }
          }
        '';
      };

      config.constructFiles.keymap = {
        relPath = "zed/keymap.json";
        content = ''
          [
            {
              "context": "Workspace",
              "bindings": {
                "ctrl-p": "file_finder::Toggle",
                "ctrl-shift-p": "command_palette::Toggle"
              }
            }
          ]
        '';
      };

      config.constructFiles.snippets = {
        relPath = "zed/snippets/nix.json";
        content = ''
          {
            "Nix Module": {
              "prefix": "nix",
              "body": ["{", "  pkgs,", "  ...", "}:", "", "{", "  $0", "}"],
              "description": "标准 Nix module 模板"
            },
            "flake.nixosModules": {
              "prefix": "nixosmod",
              "body": ["{", "  flake.nixosModules.$1 = {", "    $0", "  };", "}"],
              "description": "flake-parts: 定义 NixOS module"
            },
            "flake.nixosConfigurations": {
              "prefix": "nixos",
              "body": ["{", "  flake.nixosConfigurations.$1 = inputs.nixpkgs.lib.nixosSystem {", "    system = \"$2\";", "    modules = [", "      $0", "    ];", "  };", "}"],
              "description": "flake-parts: 定义 NixOS configuration"
            },
            "flake.homeModules": {
              "prefix": "homemod",
              "body": ["{", "  flake.homeModules.$1 = {", "    $0", "  };", "}"],
              "description": "flake-parts: 定义 Home Manager module"
            },
            "flake.darwinModules": {
              "prefix": "darwinmod",
              "body": ["{", "  flake.darwinModules.$1 = {", "    $0", "  };", "}"],
              "description": "flake-parts: 定义 nix-darwin module"
            },
            "flake.darwinConfigurations": {
              "prefix": "darwin",
              "body": ["{", "  flake.darwinConfigurations.$1 = inputs.nix-darwin.lib.darwinSystem {", "    system = \"$2\";", "    modules = [", "      $0", "    ];", "  };", "}"],
              "description": "flake-parts: 定义 nix-darwin configuration"
            },
            "flake.packages": {
              "prefix": "package",
              "body": ["{", "  perSystem = {", "    pkgs,", "    ...", "  }: {", "    packages.$1 = $0;", "  };", "}"],
              "description": "flake-parts: 定义 package"
            },
            "flake.apps": {
              "prefix": "app",
              "body": ["{", "  perSystem = {", "    pkgs,", "    ...", "  }: {", "    apps.$1 = {", "      type = \"app\";", "      program = \"''${pkgs.lib.getExe $2}\";", "    };", "  };", "}"],
              "description": "flake-parts: 定义 app"
            },
            "flake.devShells": {
              "prefix": "devshell",
              "body": ["{", "  perSystem = {", "    pkgs,", "    ...", "  }: {", "    devShells.$1 = pkgs.mkShell {", "      packages = with pkgs; [", "        $0", "      ];", "    };", "  };", "}"],
              "description": "flake-parts: 定义 devShell"
            },
            "flake.checks": {
              "prefix": "check",
              "body": ["{", "  perSystem = {", "    pkgs,", "    ...", "  }: {", "    checks.$1 = $0;", "  };", "}"],
              "description": "flake-parts: 定义 check"
            },
            "flake.lib": {
              "prefix": "flib",
              "body": ["{", "  flake.lib.$1 = $0;", "}"],
              "description": "flake-parts: 定义 flake library"
            },
            "flake.overlays": {
              "prefix": "overlay",
              "body": ["{", "  flake.overlays.$1 = final: prev: {", "    $0", "  };", "}"],
              "description": "flake-parts: 定义 overlay"
            },
            "flake.templates": {
              "prefix": "template",
              "body": ["{", "  flake.templates.$1 = {", "    path = ./templates/$1;", "    description = \"$2\";", "  };", "}"],
              "description": "flake-parts: 定义 flake template"
            },
            "flake-parts perSystem": {
              "prefix": "persystem",
              "body": ["{", "  perSystem = {", "    pkgs,", "    system,", "    ...", "  }: {", "    $0", "  };", "}"],
              "description": "flake-parts: perSystem 模块"
            },
            "flake-parts module": {
              "prefix": "fpmodule",
              "body": ["{", "  imports = [", "    $0", "  ];", "", "  $1", "}"],
              "description": "flake-parts: 模块文件模板"
            }
          }
        '';
      };

      config.runShell = [
        ''mkdir -p "$HOME/.config/zed/snippets"''
        ''cp -f ${config.constructFiles.settings.path} "$HOME/.config/zed/settings.json"''
        ''cp -f ${config.constructFiles.keymap.path} "$HOME/.config/zed/keymap.json"''
        ''cp -f ${config.constructFiles.snippets.path} "$HOME/.config/zed/snippets/nix.json"''
      ];
    };
  perSystem = { pkgs, ... }: { wrappers.control_type = "exclude"; };
}
