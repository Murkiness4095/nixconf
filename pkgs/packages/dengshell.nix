# DengShell —— 原生 SSH 终端与服务器工作台
#
# 官方仓库:  https://github.com/BitsFlowCloud/DengShell
# 打包方式:  官方 x86_64 glibc 发行 deb（DengShell-linux-x64.deb），声明式解包进 /nix/store
# 可用命令:  nix run .#dengshell
# 复用方式:  把本文件放进 nix-config 树（任意层级，例如 pkgs/dengshell.nix），
#            其余模块直接用 pkgs.stdenv.hostPlatform.system 拼出的包集里的 dengshell，
#            或 self.packages."${pkgs.stdenv.hostPlatform.system}".dengshell。
#
# 升级到官方新版：只改下面的 release 块（tag + sha256）即可，url / 版本号 / 安装逻辑都从它派生。
#   tag:    nix eval --raw --impure --expr '(builtins.getFlake "github:BitsFlowCloud/DengShell").rev'   # 或直接看 Releases 页
#   sha256: 先手动下载对应 deb，再 nix hash file --type sha256 DengShell-linux-x64.deb
{
  perSystem =
    { pkgs, lib, ... }:
    let
      # ── 官方发行版声明：跟随官方更新的唯一改动点 ──────────────────────────
      release = {
        # Releases 页最新 tag，形如 v0.03-build.20261003101
        tag = "v0.03-build.20261011106";
        # deb control 中的 Version（0.3.0-101 的上游版本部分）
        version = "0.3.0";
        # `nix hash file --type sha256 DengShell-linux-x64.deb`
        sha256 = "3481612c66af6b0d2ec285aa4c95dd3e8519438a38b561c968086a397daa5736";
      };

      # 官方只发 x64 glibc 包
      asset = "DengShell-linux-x64.deb";
      srcUrl = "https://github.com/BitsFlowCloud/DengShell/releases/download/${release.tag}/${asset}";

      supported = pkgs.stdenv.hostPlatform.parsed.cpu.name == "x86_64" && pkgs.stdenv.hostPlatform.isLinux;

      # deb Depends: libc6 >= 2.35, libgtk-3-0 | libgtk-3-0t64, libwebkit2gtk-4.1-0,
      #             iputils-ping, bash
      # ELF NEEDED: libX11 / libgtk-3 / libgdk-3 / libgdk_pixbuf-2.0 / libgio-2.0 /
      #             libgobject-2.0 / libglib-2.0 / libwebkit2gtk-4.1 / libsoup-3.0 /
      #             libjavascriptcoregtk-4.1 / libc
      runtimeLibs = with pkgs; [
        gdk-pixbuf
        glib
        gtk3
        libx11
        libsoup_3
        webkitgtk_4_1
      ];

      # start.sh 的启动前检查会用到 ldd（glibc）与 ping（iputils），并用 bash 的进程替换
      runtimeBins = with pkgs; [
        bash
        glibc
        iputils
      ];

      pkg =
        pkgs.stdenv.mkDerivation {
          pname = "dengshell";
          inherit (release) version;
          src = pkgs.fetchurl {
            url = srcUrl;
            inherit (release) sha256;
          };

          # 用 dpkg 直接解 deb，不走 unpackPhase
          nativeBuildInputs = [
            pkgs.dpkg
            pkgs.makeWrapper
          ];
          dontUnpack = true;

          # patchelf 会破坏这个 Go 二进制的入口（启动即 SIGSEGV），
          # 因此保留上游 ELF，仅用 wrapper 提供库路径。
          dontAutoPatchelf = true;
          buildInputs = runtimeLibs;

          installPhase = ''
            runHook preInstall

            dpkg-deb --extract "$src" .
            chmod -R u+w .

            # start.sh 会 cd 到自身 ../.. 并以相对路径找 ./dengshell，
            # 所以整个 opt/dengshell 树（含 support/docs/licenses）原样保留。
            mkdir -p "$out/libexec/dengshell"
            cp -r opt/dengshell/. "$out/libexec/dengshell/"
            chmod 0755 \
              "$out/libexec/dengshell/dengshell" \
              "$out/libexec/dengshell/data/support/start.sh"

            install -Dm644 usr/share/icons/hicolor/256x256/apps/dengshell.png \
              "$out/share/icons/hicolor/256x256/apps/dengshell.png"
            install -Dm644 usr/share/doc/dengshell/copyright \
              "$out/share/doc/dengshell/copyright"

            install -Dm644 usr/share/applications/dengshell.desktop \
              "$out/share/applications/dengshell.desktop"
            # 官方 desktop 项 Exec 写死 /opt/dengshell，Nix 下改写为带环境的 wrapper
            substituteInPlace "$out/share/applications/dengshell.desktop" \
              --replace-fail /opt/dengshell/data/support/start.sh "$out/bin/dengshell"

            makeWrapper "$out/libexec/dengshell/data/support/start.sh" "$out/bin/dengshell" \
              --prefix PATH : ${lib.makeBinPath runtimeBins} \
              --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
              --suffix XDG_DATA_DIRS : "$out/share:${pkgs.gdk-pixbuf}/share"

            runHook postInstall
          '';

          meta = {
            description = "Native SSH terminal and server workbench (GTK3 / WebKitGTK 4.1)";
            homepage = "https://github.com/BitsFlowCloud/DengShell";
            license = lib.licenses.mit;
            mainProgram = "dengshell";
            platforms = lib.platforms.linux;
          };
        };
    in
    {
      packages.dengshell = lib.mkIf supported pkg;

      apps.dengshell = lib.mkIf supported {
        type = "app";
        program = "${pkg}/bin/dengshell";
      };

      # 真实不变量：官方 ELF 在当前 nixpkgs 的 glibc / GTK / WebKit 下必须全部解析得到，
      # 否则 start.sh 的启动前检查会直接拒绝启动。
      checks.dengshell-links = lib.mkIf supported (
        pkgs.runCommand "dengshell-links-check" { nativeBuildInputs = [ pkgs.glibc pkgs.binutils ]; } ''
          export LD_LIBRARY_PATH=${lib.makeLibraryPath runtimeLibs}
          missing=$(LC_ALL=C ldd ${pkg}/libexec/dengshell/dengshell | grep 'not found' || true)
          if [ -n "$missing" ]; then
            echo "DengShell ELF 存在未解析的依赖：" >&2
            echo "$missing" >&2
            exit 1
          fi
          touch $out
        ''
      );
    };

  # 供外部 flake 以 `inputs.<name>.flakeModules.default` 引入（单文件模块，自包含）
  flake.flakeModules.default = ./dengshell.nix;
}
