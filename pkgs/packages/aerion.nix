# Aerion —— 开源轻量级跨平台邮件客户端
#
# 官方仓库:  https://github.com/hkdb/aerion
# 打包方式:  官方预编译二进制（Linux tar.gz / macOS zip），fetchurl 声明式拉取，
#            按 perSystem 的 system 选源，不落地任何本地二进制文件。
#            Linux 为 Wails(WebKit2GTK 4.1 + GTK3) 单 ELF，用 autoPatchelfHook 补 RPATH；
#            macOS 为 Aerion.app 套件，装到 $out/Applications 并包 wrapper 供 nix run。
# 可用命令:  nix run <任意 flake/目录>#aerion
# 复用方式:  本文件自包含，拷进 nix-config 树任意层级（例如 pkgs/aerion.nix）即被 importTree 收集，
#            其他模块直接用 pkgs.stdenv.hostPlatform.system 拼出的包集里的 aerion，
#            或 self.packages."${pkgs.stdenv.hostPlatform.system}".aerion；
#            外部 flake 亦可 inputs.aerion.flakeModules.default 引入。
#
# 升级到官方新版：只改下面的 release 块（tag / version / 各平台 sha256），url 与安装逻辑全从它派生。
#   tag:    看 https://github.com/hkdb/aerion/releases/latest
#   sha256: 取官方下载链接 `https://…/<asset>?raw=true` 后
#           nix hash convert --hash-algo sha256 --to sri -- <官方 sha256 hex>
#
# 目标平台:  x86_64-linux / aarch64-linux / aarch64-darwin
{
  perSystem =
    { pkgs, lib, system, ... }:
    let
      # ── 官方发行版声明：跟随官方更新的唯一改动点 ──────────────────────────
      release = {
        # Releases 页最新 tag
        tag = "v0.3.5";
        # Info.plist / 包版本
        version = "0.3.5";
        sha256."aerion-linux-amd64.tar.gz" = "sha256-svNa4eMODk7jQV+37+IvbubwZ1LQrXqkK3+NSLpr92o=";
        sha256."aerion-linux-arm64.tar.gz" = "sha256-81W44QAAanhPOxKdsFEHHwN0o+Krx2F1PrZETdFLtko=";
        sha256."Aerion-darwin-arm64.zip" = "sha256-DS4B3QUFsT7fwocpDFcyKFmn/MefihQt/5TGuuvqdJA=";
      };
      baseUrl = "https://github.com/hkdb/aerion/releases/download/${release.tag}";

      # 本次目标平台 → 官方发行资产（tar.gz 与独立可执行文件同 BuildID，取带图标/desktop 的 tar.gz）
      sourceFor = {
        x86_64-linux = {
          url = "${baseUrl}/aerion-linux-amd64.tar.gz";
          sha256 = release.sha256."aerion-linux-amd64.tar.gz";
        };
        aarch64-linux = {
          url = "${baseUrl}/aerion-linux-arm64.tar.gz";
          sha256 = release.sha256."aerion-linux-arm64.tar.gz";
        };
        aarch64-darwin = {
          url = "${baseUrl}/Aerion-darwin-arm64.zip";
          sha256 = release.sha256."Aerion-darwin-arm64.zip";
        };
      };
      source = sourceFor.${system} or null;
      supported = source != null;

      # Linux ELF NEEDED: libwebkit2gtk-4.1 / libgtk-3 / libgdk-3 / libgdk_pixbuf-2.0 /
      #                   libsoup-3.0 / libglib-2.0 / libgio-2.0 / libgobject-2.0
      runtimeLibs = with pkgs; [
        webkitgtk_4_1
        libsoup_3
        gtk3
        glib
        gdk-pixbuf
        libx11
      ];

      linuxPkg = pkgs.stdenv.mkDerivation {
        pname = "aerion";
        inherit (release) version;
        src = pkgs.fetchurl source;

        nativeBuildInputs = [
          pkgs.autoPatchelfHook
          pkgs.makeWrapper
        ];
        dontUnpack = false;

        # tar.gz 顶层既有文件又有目录，stdenv 的单根检测会误 cd 进 icons/，钉死为当前目录
        sourceRoot = ".";

        # 上游 ELF 的 interpreter / RPATH 指向 nixpkgs 库
        autoPatchelf = true;
        buildInputs = runtimeLibs;

        installPhase = ''
          runHook preInstall

          # tar.gz 根目录即 ./aerion + ./icons + ./io.github.hkdb.Aerion.desktop
          install -Dm755 aerion "$out/libexec/aerion"

          # Wayland 后端下 WebKitGTK 2.54 的 viewport/matchMedia 尺寸算出错：
          # Wails frameless 窗口在大窗下仍塌成 narrow 响应式单栏（侧栏与列表 0 宽、
          # 阅读窗格浮层占满窗）。X11(XWayland) 后端实测三栏正常。set-default 保留可覆盖。
          makeWrapper "$out/libexec/aerion" "$out/bin/aerion" \
            --set-default GDK_BACKEND x11

          install -Dm644 io.github.hkdb.Aerion.desktop \
            "$out/share/applications/io.github.hkdb.Aerion.desktop"
          # 官方 desktop 的 Exec/TryExec 均写 aerion，Nix 下由 PATH 解析，保持原样

          mkdir -p "$out/share/icons/hicolor"
          cp -r icons/. "$out/share/icons/hicolor/"
          install -Dm644 io.github.hkdb.Aerion.png \
            "$out/share/icons/hicolor/256x256/apps/io.github.hkdb.Aerion.png"

          runHook postInstall
        '';

        meta = {
          description = "Open source lightweight cross-platform email client";
          homepage = "https://github.com/hkdb/aerion";
          license = lib.licenses.asl20;
          mainProgram = "aerion";
          platforms = [
            "x86_64-linux"
            "aarch64-linux"
          ];
        };
      };

      darwinPkg = pkgs.stdenv.mkDerivation {
          pname = "aerion";
          inherit (release) version;
          src = pkgs.fetchurl source;

          nativeBuildInputs = [ pkgs.unzip ];

          unpackPhase = ''
            runHook preUnpack
            unzip "$src"
            runHook postUnpack
          '';

          installPhase = ''
            runHook preInstall

            # Aerion.app 原样安放，供 LaunchServices/Finder 识别；套件内 Mach-O 直接可执行
            mkdir -p "$out/Applications"
            cp -r Aerion.app "$out/Applications/"

            # nix run / $out/bin 入口
            makeWrapper "$out/Applications/Aerion.app/Contents/MacOS/aerion" "$out/bin/aerion"

            runHook postInstall
          '';

          meta = {
            description = "Open source lightweight cross-platform email client";
            homepage = "https://github.com/hkdb/aerion";
            license = lib.licenses.asl20;
            mainProgram = "aerion";
            platforms = [ "aarch64-darwin" ];
          };
        };

      pkg =
        if pkgs.stdenv.hostPlatform.isDarwin then darwinPkg else linuxPkg;
    in
    {
      packages.aerion = lib.mkIf supported pkg;

      apps.aerion = lib.mkIf supported {
        type = "app";
        program = "${pkg}/bin/aerion";
      };

      # 真实不变量：autoPatchelf 补过的 ELF 必须只用 RPATH 把 NEEDED 全部解析到 nix store，
      # 不依赖任何 LD_LIBRARY_PATH；否则真机上启动即失败。
      checks.aerion-links = lib.mkIf (supported && pkgs.stdenv.hostPlatform.isLinux) (
        pkgs.runCommand "aerion-links-check"
          {
            nativeBuildInputs = with pkgs; [
              glibc
              binutils
            ];
          }
          ''
            missing=$(LC_ALL=C ldd ${pkg}/libexec/aerion | grep 'not found' || true)
            if [ -n "$missing" ]; then
              echo "Aerion ELF 存在未解析的依赖：" >&2
              echo "$missing" >&2
              exit 1
            fi
            touch $out
          ''
      );
    };

  # 供外部 flake 以 `inputs.aerion.flakeModules.default` 引入（单文件模块，自包含）
  flake.flakeModules.default = ./aerion.nix;
}
