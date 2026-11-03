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

      version = "0.9.10";
      buildId = "20261102-152242-2ad447b";
      pname = "tern";
      baseUrl = "https://build.stencil.so/d/tern/${buildId}";

      # `.stencil-cookie` is gitignored, so it comes in as the `stencilCookie`
      # flake input (a store copy). Regenerate when the session cookie changes:
      #   nix store add --mode flat --name stencil-cookie .stencil-cookie
      # then update the path in flake.nix.
      cookieFile = inputs.stencilCookie;
      curlOpts = "-b ${cookieFile}";

      assets = {
        x86_64-linux = {
          asset = "Tern-${version}-linux-x86_64.tar.gz";
          sha256 = "5bd782328df0ee2330f34f60c407a2f0252bac6e806e620d22b744bcead4c6d5";
        };
        aarch64-linux = {
          asset = "Tern-${version}-linux-arm64.tar.gz";
          sha256 = "a78ce59dcf857296c6d6d1c6801df7f4ce35281ce58ffc8e41777baa491d9cb4";
        };
        aarch64-darwin = {
          asset = "Tern-${version}-macos-arm64.dmg";
          sha256 = "4e0bcdd358ac14214bf7f0c2a0e995e392232ab4c6530c216edc8a29be454b28";
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
        inherit pname version meta src;
        nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.makeWrapper ];
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
        inherit pname version meta src;
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
      packages.${pname} =
        if pkgs.stdenv.hostPlatform.isDarwin then darwinPackage else linuxPackage;
    };
}
