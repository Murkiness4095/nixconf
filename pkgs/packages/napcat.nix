# NapCat AppImage package (flake-parts module)
{ inputs, lib, ... }:
let
  napcatMeta = {
    version = "4.18.42";
    qqVersion = "53644";
  };

  assets = {
    x86_64-linux = {
      arch = "amd64";
      hash = "sha256-f9qwLtaWUP9SXmcIZIZWyl2JH8BbHXNTmYzd2RKGtdY=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-z1PTgdtEUu7TX3lbe/XWtZKDkUYwZ4HsXPNCo4DlrNM=";
    };
  };
in
{
  perSystem =
    {
      config,
      self',
      inputs',
      system,
      ...
    }:
    let
      pkgs = import inputs.nixpkgs.outPath {
        inherit system;
        config.allowUnfree = true;
      };
      asset = assets.${system};
    in
    lib.mkIf (builtins.hasAttr system assets) {
      packages.napcat = pkgs.appimageTools.wrapType2 {
        pname = "napcat";
        version = napcatMeta.version;

        src = pkgs.fetchurl {
          url = "https://github.com/NapNeko/NapCatAppImageBuild/releases/download/v${napcatMeta.version}/QQ-${napcatMeta.qqVersion}_NapCat-v${napcatMeta.version}-${asset.arch}.AppImage";
          hash = asset.hash;
        };

        extraPkgs =
          pkgs: with pkgs; [
            libepoxy
            libffi
            xvfb-run
          ];

        extraInstallCommands = ''
                    mv $out/bin/napcat $out/bin/.napcat-wrapped
                    sed -e "s|@out@|$out|g" > $out/bin/napcat <<'EOF'
          #!/bin/sh
          NAPCAT_DATA_DIR=''${NAPCAT_DATA_DIR:-$HOME/.local/share/napcat}
          mkdir -p "$NAPCAT_DATA_DIR"

          FAKE_HOME="$NAPCAT_DATA_DIR/.home"
          rm -rf "$FAKE_HOME/.config"
          mkdir -p "$FAKE_HOME"
          ln -sfn "$NAPCAT_DATA_DIR" "$FAKE_HOME/.config"

          cd "$NAPCAT_DATA_DIR"
          export HOME="$FAKE_HOME"
          export XDG_CONFIG_HOME="$NAPCAT_DATA_DIR"
          exec @out@/bin/.napcat-wrapped "$@"
          EOF
                    chmod +x $out/bin/napcat
        '';

        meta = {
          description = "NapCat QQ Bot packaged from the official AppImage";
          homepage = "https://github.com/NapNeko/NapCatAppImageBuild";
          license = lib.licenses.unfree;
          platforms = builtins.attrNames assets;
          mainProgram = "napcat";
        };
      };
    };
}
