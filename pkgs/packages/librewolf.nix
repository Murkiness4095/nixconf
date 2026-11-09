{ lib, ... }:
let
  # 版本号：官方更新后只需修改此处并重新计算 sha256
  version = "159.0.1-1";

  # 发布页（人类可读）：https://codeberg.org/librewolf/bsys6/releases
  # 官方 CDN 的版本目录和文件名均由 version 派生，升级只改版本与各平台 hash。
  pname = "librewolf";
  srcUrl = file: "https://dl.librewolf.net/librewolf/${version}/${file}";

  # 上游各平台产物：Linux 为 AppImage，macOS 为内含 LibreWolf.app 的 .dmg（上游无 macOS AppImage）。
  # hash 与版本目录的 sha256sums.txt 一致；nix store prefetch-file --json <srcUrl> 可下载校验。
  artifacts = {
    x86_64-linux = {
      file = "${pname}-${version}-linux-x86_64-appimage.AppImage";
      hash = "sha256-Brwyp+g3WdRUyRiKcbI2sT+CqBrF8qZf+xOqlKcVFyQ=";
    };
    aarch64-linux = {
      file = "${pname}-${version}-linux-arm64-appimage.AppImage";
      hash = "sha256-Pw2htxei6nkIR52VLXO5YqjQ7I1+WyqLweba8/Kgals=";
    };
    aarch64-darwin = {
      file = "${pname}-${version}-macos-arm64-package.dmg";
      hash = "sha256-7ZKxOgFQWf2i4n6LLF3n2AGEPl+g1+6SsRvUh/XGi/Q=";
    };
  };
in
{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      src = pkgs.fetchurl {
        url = srcUrl artifacts.${system}.file;
        hash = artifacts.${system}.hash;
      };

      # AppImage 里的应用内容（usr/bin 目录树 + net.librewolf.LibreWolf.desktop + librewolf.png）
      appimageContents = pkgs.appimageTools.extract {
        inherit pname version src;
      };

      meta = {
        description = "A custom version of Firefox, focused on privacy, security and freedom";
        homepage = "https://librewolf.net";
        license = lib.licenses.mpl20;
        platforms = builtins.attrNames artifacts;
        mainProgram = pname;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      };
    in
    lib.mkIf (builtins.hasAttr system artifacts) {
      packages.librewolf =
        if pkgs.stdenv.hostPlatform.isDarwin then
          # macOS 没有 AppImage，用上游 .dmg 里的 LibreWolf.app：
          # 保持上游代码签名（dontFixup），只补一个 CLI 入口
          pkgs.stdenv.mkDerivation {
            inherit
              pname
              version
              src
              meta
              ;

            # .dmg 解包后顶层就是 LibreWolf.app，没有单一顶层目录
            sourceRoot = ".";

            nativeBuildInputs = [
              pkgs.undmg
              pkgs.makeWrapper
            ];

            # fixup 会破坏 .app 的代码签名
            dontFixup = true;

            installPhase = ''
              runHook preInstall

              mkdir -p $out/Applications
              mv LibreWolf.app $out/Applications/

              makeWrapper $out/Applications/LibreWolf.app/Contents/MacOS/${pname} $out/bin/${pname}

              runHook postInstall
            '';
          }
        else
          pkgs.appimageTools.wrapType2 {
            inherit
              pname
              version
              src
              meta
              ;

            extraPkgs =
              pkgs: with pkgs; [
                libnotify
                # Bilibili 等站点的 HTML5 播放器依赖系统的 ffmpeg 解码器（H.264/AAC 等），
                # AppImage 自带的 LibreWolf 会通过 dlopen 加载 libavcodec 等库。
                ffmpeg
                libva
              ];

            extraInstallCommands = ''
              install -m 444 -D ${appimageContents}/net.librewolf.LibreWolf.desktop \
                $out/share/applications/net.librewolf.LibreWolf.desktop
              install -m 444 -D ${appimageContents}/librewolf.png \
                $out/share/icons/hicolor/512x512/apps/librewolf.png
            '';
          };
    };
}
