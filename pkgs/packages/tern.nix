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

      version = "0.9.16";
      buildId = "20261110-215112-41a10a5";
      pname = "tern";
      baseUrl = "https://build.stencil.so/d/tern/${buildId}";

      # `.stencil-cookie` is gitignored, so it comes in as the `stencilCookie`
      # flake input (a store copy). Regenerate when the session cookie changes:
      #   nix store add --mode flat --name stencil-cookie .stencil-cookie
      # then update the path in flake.nix.
      # cookieFile = inputs.stencilCookie;
      # curlOpts = "-b ${cookieFile}";

      assets = {
        x86_64-linux = {
          asset = "Tern-${version}-linux-x86_64.tar.gz";
          sha256 = "c687e317622b428846b008da50c700ce19216a7fdf5d19555bb80d6998a87c3d";
        };
        aarch64-linux = {
          asset = "Tern-${version}-linux-arm64.tar.gz";
          sha256 = "6fed2ecbb6fd57b87906da1392d7da1d1722aafff58bf616a4b98206182028b0";
        };
        aarch64-darwin = {
          asset = "Tern-${version}-macos-arm64.dmg";
          sha256 = "1317f7eba454a098c79a67352ab35466e53e421f24bbe30679af0c4a91b1d366";
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
