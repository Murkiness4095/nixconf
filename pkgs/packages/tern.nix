# tern — Stencil Tern, the agent IDE (https://tern.build), official beta builds.
# Flake-parts module: packages.<system>.tern
#   x86_64-linux   → Tern-<v>-linux-x86_64.tar.gz  (CLI + TUI)
#   aarch64-linux  → Tern-<v>-linux-arm64.tar.gz   (CLI + TUI)
#   aarch64-darwin → Tern-<v>-macos-arm64.dmg      (Tern.app; bin/tern launches it)
#
# Assets come from the official build page (https://build.stencil.so/tern), which
# is invite-only: every /d/ request must carry the approved account's session
# cookie, so `.stencil-cookie` (Netscape cookie-file format, mode 600) sits next
# to this file and curl hands it over for the 302 to the signed R2 URL.
#   regenerate: sqlite3 <profile>/cookies.sqlite \
#     "SELECT value FROM moz_cookies WHERE host='.stencil.so'"
#   then: printf '# Netscape HTTP Cookie File\n.stencil.so\tTRUE\t/\tTRUE\t<expiry>\t__Secure-stencil_session\t<value>\n'
# A build id changes with every upstream build, so updating Tern means editing
# `version`, `buildId` and the three hashes (SHA-256 from the build API, as SRI).
{
  lib,
  inputs,
  ...
}:
{
  perSystem =
    { system, ... }:
    let
      # Tern 为闭源分发（unfree）：自建 allowUnfree 的 pkgs，
      # 否则 checkMeta 在构造 derivation 时就拒绝求值。
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      version = "0.9.8";
      buildId = "20261029-165156-f21d9a3";
      pname = "tern";
      baseUrl = "https://build.stencil.so/d/tern/${buildId}";

      cookieFile = ./.stencil-cookie;
      curlOpts = lib.optionalString (builtins.pathExists cookieFile) "-b ${cookieFile}";

      assets = {
        x86_64-linux = {
          asset = "Tern-${version}-linux-x86_64.tar.gz";
          hash = "sha256-TCCTx1UXTmAtT4bJeB5UOhVkrxrvI/NCFSLUNs9goFQ=";
        };
        aarch64-linux = {
          asset = "Tern-${version}-linux-arm64.tar.gz";
          hash = "sha256-712FgjEw+ebr2il4ZLxxIZofoUVOnwXXVpV2D1kqHQg=";
        };
        aarch64-darwin = {
          asset = "Tern-${version}-macos-arm64.dmg";
          hash = "sha256-w1Tj65Xa7TeOSaFbxBkJv9uXIXZP7u14TmRopijm7+c=";
        };
      };

      meta = {
        description = "Tern — the agent IDE: terminals, panes and agents in one workspace";
        homepage = "https://tern.build";
        changelog = "https://build.stencil.so/tern";
        license = lib.licenses.unfree;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
        mainProgram = pname;
        platforms = builtins.attrNames assets;
        maintainers = [ ];
      };

      src = pkgs.fetchurl {
        url = "${baseUrl}/${assets.${system}.asset}";
        inherit (assets.${system}) hash;
        name = assets.${system}.asset;
        inherit curlOpts;
      };

      # Tern-<v>-linux-*.tar.gz holds a single Rust binary at tern/tern.
      linuxPackage = pkgs.stdenv.mkDerivation {
        inherit
          pname
          version
          meta
          src
          ;
        nativeBuildInputs = [
          pkgs.autoPatchelfHook
          pkgs.makeWrapper
        ];
        buildInputs = [ pkgs.stdenv.cc.cc.lib ];
        # Tern dlopen()s its display/GPU stack at runtime, so autoPatchelfHook
        # cannot see these as DT_NEEDED entries. Put them on LD_LIBRARY_PATH.
        installPhase = ''
          runHook preInstall
          # The tarball's single top-level directory is tern/, so unpacking
          # already put us beside the binary.
          install -Dm755 tern $out/bin/tern
          runHook postInstall
        '';
        postFixup = ''
          wrapProgram $out/bin/tern \
            --prefix LD_LIBRARY_PATH : ${
              lib.makeLibraryPath (with pkgs; [
                libxcb
                libxkbcommon
                wayland
                libglvnd
                mesa
              ])
            }
        '';
      };

      # Tern-<v>-macos-arm64.dmg holds Tern.app (Contents/MacOS/tern).
      darwinPackage = pkgs.stdenvNoCC.mkDerivation {
        inherit
          pname
          version
          meta
          src
          ;
        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.undmg
        ];
        sourceRoot = ".";
        installPhase = ''
          runHook preInstall
          mkdir -p $out/Applications $out/bin
          cp -R *.app $out/Applications/
          makeWrapper $out/Applications/Tern.app/Contents/MacOS/tern $out/bin/${pname}
          runHook postInstall
        '';
        # Never run fixup over a signed, notarized app bundle.
        dontFixup = true;
      };
    in
    lib.mkIf (builtins.hasAttr system assets) {
      packages.${pname} = if pkgs.stdenv.hostPlatform.isDarwin then darwinPackage else linuxPackage;
    };
}
