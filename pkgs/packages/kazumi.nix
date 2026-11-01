# Kazumi — 追番客户端 (Flutter desktop) https://github.com/Predidit/Kazumi
#
# 打包策略：不重新构建 Flutter 工程，而是消费官方 release 预编译产物：
#   * Linux  → .deb   （自带 /opt/Kazumi 应用树 + .desktop + hicolor 图标 + postinst 的 /usr/bin 软链）
#   * Darwin → .dmg   （universal binary，x86_64 + arm64，签名字节原样保留）
# 因此跟随上游只需改 `version` 与 `sources` 里对应的 hash。
#
# Flake-parts 模块：import 之后即得到
#   self.packages."${pkgs.stdenv.hostPlatform.system}".kazumi
# 同仓库其他模块里的用法：
#   environment.systemPackages = [ self.packages."${pkgs.stdenv.hostPlatform.system}".kazumi ];
#   # 或 perSystem 内：packages.foo = self'.packages.kazumi;
# 不在 sources 里的系统（如 x86_64-darwin）不会产生该 package。
# Darwin 分支必须在 aarch64-darwin 上构建（7zz 解 dmg + 保留签名，无法从 Linux 交叉构建）。
{
  lib,
  ...
}:
let
  version = "2.4.2";

  releaseUrl =
    artifact: "https://github.com/Predidit/Kazumi/releases/download/${version}/${artifact}";

  # 上游更新步骤：把 version 改成新 tag，再把三个 hash 换成新产物。
  # hash 取自 GitHub release API 的 `digest` 字段，等价于 `nix hash file <下载的产物>`。
  sources = {
    x86_64-linux = {
      artifact = "Kazumi_linux_${version}_amd64.deb";
      hash = "sha256-vxvPDMy50urtsyVCm25qL654qo/gHM6MfL4vFVcHQZ0=";
    };
    aarch64-linux = {
      artifact = "Kazumi_linux_${version}_arm64.deb";
      hash = "sha256-uQiImjfpzeckbjqAcRqllA6XE6IODslqhzAriceNkAY=";
    };
    aarch64-darwin = {
      artifact = "Kazumi_macos_${version}.dmg";
      hash = "sha256-Sx8Mhv0jte6ITVOGSqrHj5ezEX+ruUL/GNNR340MopA=";
    };
  };

  mkSrc =
    pkgs: system:
    pkgs.fetchurl {
      name = sources.${system}.artifact;
      url = releaseUrl sources.${system}.artifact;
      hash = sources.${system}.hash;
    };

  meta = {
    description = "Anime streaming client with danmaku support";
    longDescription = ''
      Kazumi 是一个基于 Flutter 的跨平台追番客户端，支持弹幕、多视频源与本地/远程弹幕服务器。
      本包直接封装上游 release 的预编译产物。
    '';
    homepage = "https://github.com/Predidit/Kazumi";
    license = lib.licenses.gpl3Only;
    mainProgram = "kazumi";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };

  # ---------------------------------------------------------------- Linux (deb)
  mkLinux =
    { pkgs, src }:
    pkgs.stdenv.mkDerivation {
      pname = "kazumi";
      inherit version src meta;

      nativeBuildInputs = with pkgs; [
        dpkg
        patchelf
        autoPatchelfHook
        makeWrapper
      ];

      # deb 的 Depends 加上 Flutter GTK 运行期实际链接的库；
      # 尾部若干项是随包的 libmpv.so.2（静态 ffmpeg）自身 NEEDED 的硬件解码/依赖库。
      buildInputs = with pkgs; [
        gtk3
        glib
        gdk-pixbuf
        pango
        cairo
        atk
        libepoxy
        webkitgtk_4_1
        libayatana-appindicator
        alsa-lib
        zlib
        libva
        libvdpau
        libarchive
        libXScrnSaver
        libXv
      ];

      # deb 里 data.tar.zst 的解压交给 dpkg-deb，顺带保留文件权限。
      unpackPhase = ''
        runHook preUnpack
        dpkg-deb --extract "$src" .
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/opt/kazumi
        cp -a opt/Kazumi/. $out/opt/kazumi/

        # libdartjni.so 是上游构建目录里的 JNI 辅助库，Linux 端没有任何代码路径加载它
        # （Dart AOT 快照与插件均未引用），但它的 NEEDED 指向 JDK 私有的 libjvm.so。
        # 去掉这个依赖即可避免为了一个死库把整个 JDK 拖进闭包。
        patchelf --remove-needed libjvm.so $out/opt/kazumi/lib/libdartjni.so

        # deb 的 postinst 在系统里做的两件事，在 Nix 里等价写成 $out 布局。
        #
        # 启动器必须走包装器，两个原因：
        #  1) libmpv.so.2、libech_http.so 等 Flutter code asset 是以裸 soname 交给
        #     dlopen 的（调用方是 libflutter_linux_gtk.so，glibc 只搜调用者自身的
        #     RUNPATH），bundle 的 lib 目录必须出现在 LD_LIBRARY_PATH 里。
        #  2) hive_ce_flutter 的 Hive.initFlutter() 会先调
        #     getApplicationDocumentsDirectory()，path_provider_linux 进而执行
        #     `xdg-user-dir DOCUMENTS`；宿主没有 xdg-user-dirs 时该调用返回 null，
        #     应用启动即报 MissingPlatformDirectoryException，故把它带进 PATH。
        mkdir -p $out/bin
        makeWrapper $out/opt/kazumi/kazumi $out/bin/kazumi \
          --prefix LD_LIBRARY_PATH : $out/opt/kazumi/lib \
          --prefix PATH : ${lib.makeBinPath [ pkgs.xdg-user-dirs ]}

        install -Dm644 usr/share/applications/io.github.Predidit.Kazumi.desktop \
          $out/share/applications/io.github.Predidit.Kazumi.desktop
        install -Dm644 usr/share/icons/hicolor/512x512/apps/io.github.Predidit.Kazumi.png \
          $out/share/icons/hicolor/512x512/apps/io.github.Predidit.Kazumi.png

        runHook postInstall
      '';

      # libapp.so 是 Dart AOT 快照，strip 有损坏快照的风险；上游 release 本就是 strip 过的。
      dontStrip = true;

      # autoPatchelfHook 会把 $ORIGIN/lib 之外补上 nix 库路径：主程序以裸 soname
      # 链接 lib/*.so，必须保留 $ORIGIN/lib。
      appendRunpaths = [ "$ORIGIN/lib" ];
    };

  # -------------------------------------------------------------- Darwin (dmg)
  mkDarwin =
    { pkgs, src }:
    pkgs.stdenv.mkDerivation {
      pname = "kazumi";
      inherit version src meta;

      # 7zz 支持 APFS 格式的 dmg；nixpkgs 的 undmg (libdmg-hfsplus) 只支持 HFS+。
      nativeBuildInputs = [ pkgs._7zz ];

      unpackPhase = ''
        runHook preUnpack
        7zz x -bd -o"dmg" "$src"
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/Applications
        cp -R dmg/Kazumi.app $out/Applications/Kazumi.app
        chmod +x $out/Applications/Kazumi.app/Contents/MacOS/Kazumi

        mkdir -p $out/bin
        ln -s $out/Applications/Kazumi.app/Contents/MacOS/Kazumi $out/bin/kazumi

        runHook postInstall
      '';

      # .app 里带厂商代码签名（arm64 必须保持有效），任何 fixup 都可能破坏它，
      # 因此整个 fixupPhase 直接跳过；bundle 内部依赖用 @rpath 相对定位，无需修改。
      dontFixup = true;
    };
in
{
  perSystem =
    { pkgs, system, ... }:
    lib.mkIf (sources ? ${system}) {
      packages.kazumi =
        let
          src = mkSrc pkgs system;
        in
        if pkgs.stdenv.hostPlatform.isDarwin then
          mkDarwin { inherit pkgs src; }
        else
          mkLinux { inherit pkgs src; };
    };
}
