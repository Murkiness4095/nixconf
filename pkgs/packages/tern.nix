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

      version = "0.9.9";
      buildId = "20261031-151729-9c1c09f";
      pname = "tern";
      baseUrl = "https://build.stencil.so/d/tern/${buildId}";

      cookieFile = ./.stencil-cookie;
      curlOpts = lib.optionalString (builtins.pathExists cookieFile) "-b ${cookieFile}";

      assets = {
        x86_64-linux = {
          asset = "Tern-${version}-linux-x86_64.tar.gz";
          sha256 = "04565b2da6e232f4ca1ca40a2e56aa28a26f89fc1094634906584631e413993f";
        };
        aarch64-linux = {
          asset = "Tern-${version}-linux-arm64.tar.gz";
          sha256 = "bdfc119cbebda065ae517ec718e2a81071598e0a95e2f8b53bf94bbacb760b88";
        };
        aarch64-darwin = {
          asset = "Tern-${version}-macos-arm64.dmg";
          sha256 = "ffebab0f3b64ef1b40cc036c9984753f1e2c0db5f4dba485cad1917f4cbb190f";
        };
      };

      meta = {
        description = "Tern — the agent IDE: terminals, panes and agents in one workspace";
        homepage = "https://tern.build";
        license = lib.licenses.unfree;
        mainProgram = pname;
        platforms = builtins.attrNames assets;
      };

      src = pkgs.fetchurl {
        url = "${baseUrl}/${assets.${system}.asset}";
        sha256 = assets.${system}.sha256;
        name = assets.${system}.asset;
        inherit curlOpts;
      };

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
        buildInputs = [
          pkgs.stdenv.cc.cc.lib
          pkgs.libxcb
          pkgs.libxkbcommon
          pkgs.mesa
          pkgs.vulkan-loader
          pkgs.glib
        ];
        installPhase = ''
          runHook preInstall
          install -Dm755 tern $out/bin/tern
          runHook postInstall
        '';
        postFixup = ''
          wrapProgram $out/bin/tern \
            --prefix LD_LIBRARY_PATH : ${pkgs.libxcb}/lib:${pkgs.libxkbcommon}/lib:${pkgs.mesa}/lib:${pkgs.vulkan-loader}/lib \
            --prefix PATH : ${pkgs.glib}/bin
        '';
      };

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
        dontFixup = true;
      };
    in
    lib.mkIf (builtins.hasAttr system assets) {
      packages.${pname} = if pkgs.stdenv.hostPlatform.isDarwin then darwinPackage else linuxPackage;
    };
}
