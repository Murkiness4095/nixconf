# brave-origin — Brave Origin (https://brave.com/origin/linux/), 官方 .deb 二进制。
#
# 打包方式：官方预编译 .deb，fetchurl 声明式拉取，按 perSystem 的 system 选源，
#           不落地任何本地二进制文件。deb 内是 Chromium 目录树
#           /opt/brave.com/brave-origin/（brave + 上游 shell wrapper + chrome-sandbox），
#           用 dpkg 解包、patchelf 补 Nix 动态链接器与 RPATH，wrapGAppsHook3 生成最终 wrapper。
#
# 资产来源：https://brave.com/origin/linux/ 的 apt 源（brave-browser-apt-release.s3.brave.com）
#           与 GitHub Release 上是同一份文件，SHA-256 完全一致；这里用 GitHub 的稳定 URL，
#           hash 取 GitHub 资产的 digest（= apt 索引里的 SHA256）。
#
# 升级到官方新版：只改 version 与两个 hash，URL 从它们派生。
#   nix store prefetch-file --json https://github.com/brave/brave-browser/releases/download/v<ver>/brave-origin_<ver>_amd64.deb
#
# 目标平台：x86_64-linux / aarch64-linux
{
  lib,
  inputs,
  ...
}:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs { inherit system; };

      version = "1.99.55";
      pname = "brave-origin";
      owner = "brave";
      repo = "brave-browser";
      baseUrl = "https://github.com/${owner}/${repo}/releases/download/v${version}";

      assets = {
        x86_64-linux = {
          arch = "amd64";
          hash = "sha256-YxmkjQ/8IF+FW4wkI/cKy19jtoghTxG7W2EL0xeT/Gs=";
        };
        aarch64-linux = {
          arch = "arm64";
          hash = "sha256-WSxFq+JX35bO1zFzbbuC/eHPlbiX75hIo0R1dmluOSs=";
        };
      };

      # /opt/brave.com/<optName>/，deb 里的目录名与上游 wrapper 名同源。
      optName = "brave-origin";
      fileBase = "brave-origin";
      appId = "com.brave.Origin";
      innerBinary = "brave";
      upstreamBin = "brave-origin-stable";

      # Chromium 运行时依赖（对齐 nixpkgs 的 brave 配方）。
      deps = with pkgs; [
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        gtk4
        libdrm
        libx11
        libGL
        libxkbcommon
        libxscrnsaver
        libxcomposite
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxi
        libxrandr
        libxrender
        libxshmfence
        libxtst
        libuuid
        libgbm
        nspr
        nss
        pango
        pciutils
        pipewire
        udev
        wayland
        libxcb
        zlib
        snappy
        speechd-minimal
        libkrb5
        vulkan-loader
        qt6.qtbase
        libpulseaudio
        libva
      ];

      rpath = lib.makeLibraryPath deps + ":" + lib.makeSearchPathOutput "lib" "lib64" deps;
      binpath = lib.makeBinPath deps;

      meta = {
        description = "Brave Origin — stripped-down Brave with only the privacy core";
        homepage = "https://brave.com/origin/";
        changelog = "https://github.com/${owner}/${repo}/blob/master/CHANGELOG_DESKTOP_ORIGIN.md";
        license = lib.licenses.mpl20;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
        mainProgram = pname;
        platforms = builtins.attrNames assets;
        maintainers = [ ];
      };

      brave-origin = pkgs.stdenv.mkDerivation {
        inherit pname version meta;

        src = pkgs.fetchurl {
          url = "${baseUrl}/${pname}_${version}_${assets.${system}.arch}.deb";
          inherit (assets.${system}) hash;
        };

        nativeBuildInputs = [
          pkgs.dpkg
          # 上游 $out/bin 入口是指向 shell wrapper 的符号链接，需要能包脚本的 wrapper。
          (pkgs.buildPackages.wrapGAppsHook3.override {
            makeWrapper = pkgs.buildPackages.makeShellWrapper;
          })
        ];

        buildInputs = [
          # GSETTINGS_SCHEMAS_PATH / XDG_ICON_DIRS 来源
          pkgs.glib
          pkgs.gsettings-desktop-schemas
          pkgs.gtk3
          pkgs.gtk4
          pkgs.adwaita-icon-theme
        ];

        __structuredAttrs = true;
        strictDeps = true;
        dontConfigure = true;
        dontBuild = true;
        dontPatchELF = true;

        unpackPhase = ''
          runHook preUnpack
          # chrome-sandbox 是 setuid 的，沙箱里无权设置该位，用 --no-same-permissions 解包
          dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions
          runHook postUnpack
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out $out/bin

          cp -R usr/share $out
          cp -R opt/ $out/opt

          export BINARYWRAPPER=$out/opt/brave.com/${optName}/${fileBase}

          # 修掉上游 wrapper 的 /bin/bash 与 CHROME_WRAPPER 标记
          substituteInPlace $BINARYWRAPPER \
            --replace-fail /bin/bash ${pkgs.stdenv.shell} \
            --replace-fail 'CHROME_WRAPPER' 'WRAPPER'

          ln -sf $BINARYWRAPPER $out/bin/${pname}

          for exe in $out/opt/brave.com/${optName}/{${innerBinary},chrome_crashpad_handler}; do
            patchelf \
              --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
              --set-rpath "${rpath}" $exe
          done

          # 桌面项与默认应用声明里的绝对路径
          substituteInPlace $out/share/applications/{${fileBase},${appId}}.desktop \
            --replace-fail /usr/bin/${upstreamBin} $out/bin/${pname}
          substituteInPlace $out/share/gnome-control-center/default-apps/${fileBase}.xml \
            --replace-fail /opt/brave.com $out/opt/brave.com
          substituteInPlace $out/opt/brave.com/${optName}/default-app-block \
            --replace-fail /opt/brave.com $out/opt/brave.com

          # deb 里的图标是散装 product_logo_*.png，补成 hicolor 主题结构
          for icon in 16 24 32 48 64 128 256; do
            mkdir -p $out/share/icons/hicolor/''${icon}x''${icon}/apps
            ln -s $out/opt/brave.com/${optName}/product_logo_''${icon}.png \
              $out/share/icons/hicolor/''${icon}x''${icon}/apps/${fileBase}.png
          done

          # ANGLE 按绝对路径加载这个副本；换成 NixOS 打过补丁的 loader
          rm $out/opt/brave.com/${optName}/libvulkan.so.1
          ln -s ${pkgs.lib.getLib pkgs.vulkan-loader}/lib/libvulkan.so.1 \
            $out/opt/brave.com/${optName}/libvulkan.so.1

          # Chromium 内嵌的 xdg-settings / xdg-mime 换成系统的
          ln -sf ${pkgs.xdg-utils}/bin/xdg-settings $out/opt/brave.com/${optName}/xdg-settings
          ln -sf ${pkgs.xdg-utils}/bin/xdg-mime $out/opt/brave.com/${optName}/xdg-mime

          runHook postInstall
        '';

        preFixup = ''
          gappsWrapperArgs+=(
            --prefix LD_LIBRARY_PATH : ${rpath}
            --prefix PATH : ${binpath}
            --suffix PATH : ${
              lib.makeBinPath [
                pkgs.xdg-utils
                pkgs.coreutils
              ]
            }
            --set CHROME_WRAPPER ${pname}
            --add-flags "--disable-features=OutdatedBuildDetector"
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto}}"
          )
        '';

        # 不走上游 wrapper（它会吞掉错误），直接问二进制
        doInstallCheck = true;
        installCheckPhase = ''
          $out/opt/brave.com/${optName}/${innerBinary} --version
        '';
      };
    in
    lib.mkIf (builtins.hasAttr system assets) {
      packages.brave-origin = brave-origin;
    };
}
