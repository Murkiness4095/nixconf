{
  inputs,
  ...
}:
{
  flake.wrappers.vscode =
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

      config.package = pkgs.vscode;

      config.constructFiles.settings = {
        relPath = "User/settings.json";
        content = ''
          {
            "locale": "zh-CN",
            "editor.fontFamily": "'ComicShannsMono Nerd Font', 'LXGW WenKai', 'JetBrainsMono Nerd Font', monospace",
            "editor.fontSize": 14,
            "editor.tabSize": 2,
            "files.autoSave": "onFocusChange",
            "editor.formatOnSave": true,
            "[nix]": {
              "editor.defaultFormatter": "jnoortheen.nix-ide",
              "editor.formatOnSave": true
            },
            "nix.enableLanguageServer": true,
            "nix.serverPath": "nil",
            "nix.formatterPath": "nixfmt",
            "[scheme]": {
              "editor.tabSize": 2,
              "editor.insertSpaces": true,
              "editor.detectIndentation": false,
              "editor.autoIndent": "full",
              "editor.formatOnSave": true,
              "editor.bracketPairColorization.enabled": true
            },
            "parinfer.mode": "smart",
            "parinfer.forceBalance": true,
            "files.exclude": { "**/.git": false },
            "gitlens.ai.model": "vscode",
            "gitlens.ai.vscode.model": "copilotcli:"
          }
        '';
      };

      config.constructFiles.argv = {
        relPath = "User/argv.json";
        content = ''
          {
            "locale": "zh-cn",
            "enable-crash-reporter": true,
            "password-store": "basic"
          }
        '';
      };

      config.constructFiles.snippets = {
        relPath = "User/snippets/nix.code-snippets";
        content = ''
          {
            "Home Manager / NixOS Module Template": {
              "prefix": "nix",
              "body": ["{", "  pkgs,", "  ...", "}:", "", "{", "  $0", "}"],
              "description": "快速生成标准 Nix 模块结构"
            }
          }
        '';
      };

      config.runShell = [
        ''mkdir -p "$HOME/.config/Code/User/snippets"''
        ''cp -f ${config.constructFiles.settings.path} "$HOME/.config/Code/User/settings.json"''
        ''cp -f ${config.constructFiles.argv.path} "$HOME/.config/Code/User/argv.json"''
        ''cp -f ${config.constructFiles.snippets.path} "$HOME/.config/Code/User/snippets/nix.code-snippets"''
      ];
    };
  perSystem = { system, ... }: {
    wrappers.control_type = "exclude";
    wrappers.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  };
}
