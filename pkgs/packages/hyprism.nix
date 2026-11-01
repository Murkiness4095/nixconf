# HyPrism 的 flake-parts 模块。
# 直接封装官方 4.0.0 二进制：Linux x86_64 AppImage 与 macOS ARM64 DMG。
# 上游此版本没有 ARM Linux 产物，因此该系统不导出 hyprism/default。
#
# Linux 启动器沿用 bubblewrap 包装，为游戏启动时的绝对路径 /bin/chmod 补充 /bin。
# 这里使用 bubblewrap 创建一个只补充 /bin 的轻量挂载命名空间：
# 其余文件系统（/nix、/run、/home、/dev、/proc 等）全部透传，
# 因此仍保留 nix-ld 与宿主 GPU/图形驱动环境，启动器窗口可正常显示。
#
# /bin 的内容在构建时固定到 $out/lib/hyprism-bin（coreutils + bash），
# 通过 bwrap 只读挂载，不会因为运行时临时目录被清理而失效。
#
# 更新版本时，对 sources 中的官方产物运行 nix store prefetch-file --json <URL>，
# 将实测 SRI hash 填入对应平台；Darwin 保留 .app 的签名字节，跳过 fixup。
# Linux 保留原有宿主 nix-ld/图形库依赖；bwrap 挂载要求 /bin 为目录而非符号链接。
{ lib, ... }:

{
  perSystem =
    { pkgs, system, ... }:
    let
      version = "4.0.0";
      pname = "hyprism";
      sources = {
        x86_64-linux = {
          artifact = "Hyprism-linux-x64-${version}.AppImage";
          hash = "sha256-KQxyy9dlvLFLmxJ++aXPlyPG23XZ/NBnrKC0F8fvMog=";
        };
        aarch64-darwin = {
          artifact = "Hyprism-mac-arm64-${version}.dmg";
          hash = "sha256-R3wWDgSMpF0IUv5MNJ1JJlmoePWxz71uS0omG1ehXHg=";
        };
      };
      src = pkgs.fetchurl {
        url = "https://github.com/hyprismteam/HyPrism/releases/download/v${version}/${sources.${system}.artifact}";
        inherit (sources.${system}) hash;
      };

      appimageContents = pkgs.appimageTools.extract {
        inherit pname version src;
      };

      bwrap = pkgs.bubblewrap;
      coreutils = pkgs.coreutils;
      bash = pkgs.bash;
      zenity = pkgs.zenity;
      cacert = pkgs.cacert;
    in
    lib.mkIf (sources ? ${system}) {
      packages = rec {
        hyprism = pkgs.stdenvNoCC.mkDerivation {
          pname = "hyprism";
          inherit version;

          dontUnpack = true;
          nativeBuildInputs = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs._7zz ];
          dontFixup = pkgs.stdenv.hostPlatform.isDarwin;

          installPhase =
            if pkgs.stdenv.hostPlatform.isDarwin then
              ''
                runHook preInstall

                7zz x -bd -o"dmg" ${src}
                mkdir -p "$out/Applications" "$out/bin"
                cp -R "dmg/Hyprism Launcher.app" "$out/Applications/Hyprism Launcher.app"
                chmod +x "$out/Applications/Hyprism Launcher.app/Contents/MacOS/Hyprism Launcher"
                ln -s "$out/Applications/Hyprism Launcher.app/Contents/MacOS/Hyprism Launcher" "$out/bin/hyprism"

                runHook postInstall
              ''
            else
              ''
                runHook preInstall

                mkdir -p $out/lib/hyprism
                cp -r ${appimageContents}/usr/lib/hyprism/. $out/lib/hyprism/

                # 构建一个持久化的 /bin 目录，供 bwrap 挂载。
                mkdir -p $out/lib/hyprism-bin
                ${coreutils}/bin/cp -s ${coreutils}/bin/* $out/lib/hyprism-bin/
                ${coreutils}/bin/ln -sf ${bash}/bin/bash $out/lib/hyprism-bin/sh
                ${coreutils}/bin/ln -sf ${bash}/bin/bash $out/lib/hyprism-bin/bash

                mkdir -p $out/bin
                cp ${pkgs.writeShellScript "hyprism-launcher" ''
                  export PATH="${zenity}/bin:$PATH"
                  export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
                  export SSL_CERT_DIR="${cacert}/etc/ssl/certs"
                  # 4.0.0 改用 .NET/Avalonia，ICU 与 OpenSSL 由运行时通过 dlopen 查找。
                  export LD_LIBRARY_PATH="${
                    lib.makeLibraryPath [
                      pkgs.icu
                      pkgs.openssl
                    ]
                  }''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
                  # 在进入命名空间前解析宿主配置，避免 /etc/fonts 间接指向未挂载路径。
                  export FONTCONFIG_PATH="''${FONTCONFIG_PATH:-$(${coreutils}/bin/readlink -f /etc/fonts)}"
                  export FONTCONFIG_FILE="''${FONTCONFIG_FILE:-$FONTCONFIG_PATH/fonts.conf}"

                  mounts=()
                  for dir in / /dev /proc /run /sys /tmp /home /nix /boot /mnt /var /srv /media /etc; do
                    [ -d "$dir" ] || continue
                    case "$dir" in
                      /dev) mounts+=(--dev-bind /dev /dev) ;;
                      /proc) mounts+=(--proc /proc) ;;
                      *) mounts+=(--bind "$dir" "$dir") ;;
                    esac
                  done
                  [ -d /opt ] && mounts+=(--bind-try /opt /opt)

                  if ${bwrap}/bin/bwrap --version >/dev/null 2>&1; then
                    exec ${bwrap}/bin/bwrap \
                      "''${mounts[@]}" \
                      --ro-bind "@out@/lib/hyprism-bin" /bin \
                      -- \
                      "@out@/lib/hyprism/Hyprism Launcher" \
                      "$@"
                  fi

                  # 如果 bwrap 不可用（例如未启用用户命名空间），
                  # 仍尝试直接启动启动器；游戏启动时仍会因 /bin/chmod 失败。
                  exec "@out@/lib/hyprism/Hyprism Launcher" "$@"
                ''} $out/bin/hyprism
                chmod +x $out/bin/hyprism
                substituteInPlace $out/bin/hyprism --replace-fail "@out@" "$out"

                mkdir -p $out/share/applications $out/share/icons/hicolor/scalable/apps
                cp ${appimageContents}/io.github.hyprismteam.Hyprism.desktop $out/share/applications/io.github.hyprismteam.Hyprism.desktop
                cp ${appimageContents}/io.github.hyprismteam.Hyprism.svg $out/share/icons/hicolor/scalable/apps/io.github.hyprismteam.Hyprism.svg

                substituteInPlace $out/share/applications/io.github.hyprismteam.Hyprism.desktop \
                  --replace-fail 'Exec=hyprism' "Exec=$out/bin/hyprism"

                runHook postInstall
              '';

          meta = with pkgs.lib; {
            description = "A multiplatform Hytale launcher with mod manager";
            homepage = "https://github.com/hyprismteam/HyPrism";
            license = licenses.gpl3;
            maintainers = [ ];
            platforms = builtins.attrNames sources;
            mainProgram = "hyprism";
            sourceProvenance = with sourceTypes; [ binaryNativeCode ];
          };
        };

        default = hyprism;
      };
    };
}
