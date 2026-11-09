# omp-gui — official oh-my-pi GUI binaries (https://github.com/nornzach/oh-my-pi-gui).
# Flake-parts module: packages.<system>.omp-gui for x86_64-linux / aarch64-darwin.
# Updates change only version and the two release hashes; icons come from the bundles.
# nix store prefetch-file --json <release URL> downloads and reports the SRI hash.
# Nix still builds the extraction/FHS launcher, not the upstream Electron application.
{
  lib,
  inputs,
  ...
}:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      version = "0.9.39";
      pname = "omp-gui";
      owner = "nornzach";
      repo = "oh-my-pi-gui";
      baseUrl = "https://github.com/${owner}/${repo}/releases/download/v${version}";

      # SRI hashes computed from the SHA-256 digests published by GitHub for
      # each release asset. Update the version and these hashes when upstream
      # ships a new release.
      hashes = {
        appimage = "sha256-cUIYlYFevZmY8RtGgSoK2xtPHOsgW9KZyxKHjJkbgkc=";
        dmg = "sha256-KZrNZkDmMU8B6O5ov9+H5CSWuj/DgmMHaJ7+u/gDupY=";
      };

      meta = {
        description = "oh-my-pi GUI — desktop client for the oh-my-pi coding agent";
        homepage = "https://github.com/${owner}/${repo}";
        license = lib.licenses.unfree;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
        mainProgram = pname;
        platforms = [
          "x86_64-linux"
          "aarch64-darwin"
        ];
        maintainers = [ ];
      };

      appimageSrc = pkgs.fetchurl {
        url = "${baseUrl}/omp-${version}.AppImage";
        hash = hashes.appimage;
      };

      appimageContents = pkgs.appimageTools.extract {
        inherit pname version;
        src = appimageSrc;
      };

      linuxPackage = pkgs.appimageTools.wrapType2 {
        inherit pname version meta;
        src = appimageSrc;
        extraInstallCommands = ''
          install -Dm644 ${appimageContents}/omp-gui.desktop \
            $out/share/applications/omp-gui.desktop
          substituteInPlace $out/share/applications/omp-gui.desktop \
            --replace-fail 'Exec=AppRun' 'Exec=omp-gui' \
            --replace-fail 'Name=omp' 'Name=omp-gui'
          mkdir -p $out/share/icons
          cp -r ${appimageContents}/usr/share/icons/hicolor $out/share/icons/
        '';
      };

      # aarch64-darwin: extract the arm64 DMG and wrap the .app executable.
      darwinPackage = pkgs.stdenvNoCC.mkDerivation {
        inherit pname version meta;
        src = pkgs.fetchurl {
          url = "${baseUrl}/omp-${version}-arm64.dmg";
          hash = hashes.dmg;
        };
        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.undmg
        ];
        sourceRoot = ".";
        installPhase = ''
          runHook preInstall
          mkdir -p $out/Applications $out/bin
          cp -r *.app $out/Applications/
          makeWrapper $out/Applications/omp.app/Contents/MacOS/omp $out/bin/omp-gui
          runHook postInstall
        '';
        # Do not run fixup on a signed/notarized macOS app bundle.
        dontFixup = true;
      };
    in
    lib.mkIf (builtins.elem system meta.platforms) {
      packages.omp-gui = if pkgs.stdenv.hostPlatform.isDarwin then darwinPackage else linuxPackage;
    };
}
