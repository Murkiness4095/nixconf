# NapCat AppImage package (flake-parts module)
# Only x86_64-linux is supported by the upstream binary.
{ inputs, lib, ... }:
let
  # Upstream release metadata.
  # Update these fields when a new NapCat AppImage is released.
  napcatMeta = {
    version = "4.18.19";
    qqVersion = "50969";
    hash = "sha256-UebH9+PRcyqitGBVQqWLibAfn9B9kA+14qpNzj+8Sts=";
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
    in
    lib.mkIf (system == "x86_64-linux") {
      packages.napcat = pkgs.appimageTools.wrapType2 {
        pname = "napcat";
        version = napcatMeta.version;

        src = pkgs.fetchurl {
          url = "https://github.com/NapNeko/NapCatAppImageBuild/releases/download/v${napcatMeta.version}/QQ-${napcatMeta.qqVersion}_NapCat-v${napcatMeta.version}-amd64.AppImage";
          inherit (napcatMeta) hash;
        };

        # The bundled AppRun expects xvfb-run to be available in the FHS
        # environment. libffi is required by the bundled QQ binary but not
        # included in the default AppImage FHS environment.
        extraPkgs =
          pkgs: with pkgs; [
            libepoxy
            libffi
            xvfb-run
          ];

        # NapCat's AppRun sets NAPCAT_WORKDIR=$(pwd), so the NapCat data
        # directory depends on the current working directory. QQ also stores
        # data under ~/.config/QQ and ignores XDG_CONFIG_HOME in some code
        # paths. Wrap the launcher with a fake HOME so everything is unified
        # under $NAPCAT_DATA_DIR.
        #
        # Unified layout:
        #   $NAPCAT_DATA_DIR          -> NapCat workdir (config, logs, cache, plugins)
        #   $NAPCAT_DATA_DIR/QQ       -> QQ client data
        extraInstallCommands = ''
                    mv $out/bin/napcat $out/bin/.napcat-wrapped
                    sed -e "s|@out@|$out|g" > $out/bin/napcat <<'EOF'
          #!/bin/sh
          NAPCAT_DATA_DIR=''${NAPCAT_DATA_DIR:-$HOME/.local/share/napcat}
          mkdir -p "$NAPCAT_DATA_DIR"

          # QQ's native code hard-codes ~/.config/QQ in some places and ignores
          # XDG_CONFIG_HOME. Use a fake HOME so that ~/.config/QQ resolves inside the
          # NapCat data directory.
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
          platforms = [ "x86_64-linux" ];
          mainProgram = "napcat";
        };
      };
    };
}
