{ inputs, self, ... }:
{
  flake.nixosModules.desktop-pkgs =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      services.flatpak.enable = true;

      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      environment.systemPackages = with pkgs; [
        # browser
        brave-origin
        selfpkgs.librewolf

        # chat
        deltachat-desktop
        selfpkgs.aerion
        selfpkgs.vesktop # 内置 Vencord 的 Discord 替代客户端
        selfpkgs.nheko # Desktop client for the Matrix protocol
        selfpkgs.telegram
        selfpkgs.dingtalk
        selfpkgs.feishu
        selfpkgs.qq
        selfpkgs.wechat
        selfpkgs.wechat-uos

        selfpkgs.fuzzel

        # download
        varia
        motrix
        qbittorrent-enhanced
        yt-dlp

        # editor
        selfpkgs.vscode
        selfpkgs.zed

        # terminal
        selfpkgs.alacritty
        selfpkgs.kitty

        # media
        selfpkgs.kazumi
        obs-studio
        celluloid # video
        imv # image
        ffmpegthumbnailer
        poppler
        libopenraw
        libgsf
        splayer-next # 开源wyy客户端

        # office
        libreoffice

        # Note
        # joplin-desktop
        obsidian
        selfpkgs.floral-notepaper

        kdePackages.kate
        kdePackages.plasma-integration

        # book
        readest

        # tools
        android-tools
        payload-dumper-go
        localsend
        scrcpy
        qtscrcpy
        picocom
        # netcat-openbsd
        inetutils
        mission-center
        # ssh
        selfpkgs.dengshell

        # 剪贴板
        wl-clipboard
        cliphist

        # gaming
        selfpkgs.bottles
        selfpkgs.heroic
        hmcl
        selfpkgs.hyprism
        mangohud
        # proton/wine
        protonplus
        umu-launcher
        protontricks
        winetricks
        # Switch
        eden
        ryubing

        # 截图
        grim
        slurp
        satty # 截图编辑标注

        file-roller # 解压工具

        # 控屏
        # input-leap  # kvm软件
        rustdesk-flutter
        moonlight-qt

        # 磁盘工具
        # gparted-full
        gnome-disk-utility
        ntfsprogs-plus

        bazaar # flatpak的图形化管理工具
        # gearlever # AppImages 管理工具
        warehouse

        nwg-look # 设置gtk主题

        # vibe coding
        opencode
        # opencode-desktop
        inputs.omp-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
        selfpkgs.tern
        selfpkgs.omp-gui
        bun

        # system-pkgs
        mesa-demos
        gamescope
        gparted

        openh264
        gst_all_1.gst-libav
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly

        brightnessctl
        power-profiles-daemon

        xdg-desktop-portal
        xdg-desktop-portal-wlr

        # 解包
        libarchive
        squashfsTools

        # archives
        zip
        xz
        zstd
        unrar
        unzipNLS
        p7zip
      ];

      security.wrappers.bwrap = {
        setuid = true;
        owner = "root";
        group = "root";
        source = "${pkgs.bubblewrap}/bin/bwrap";
      };

      # no-safe
      nixpkgs.config.permittedInsecurePackages = [
        "pnpm-10.29.2"
        "electron-40.10.5"
      ];
    };

}
