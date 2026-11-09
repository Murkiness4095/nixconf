{ inputs, self, ... }:
{
  flake.nixosModules.desktop-sheng =
    { pkgs, ... }:
    let
      nixpakApps = inputs.nixpak-apps.packages.${pkgs.stdenv.hostPlatform.system};
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      imports = [
        self.nixosModules.greeter
        self.nixosModules.thunar
        self.nixosModules.fcitx5
        self.nixosModules.hjem
        self.nixosModules.theme
        self.nixosModules.i18n
        self.nixosModules.display-control
      ];

      programs.niri = {
        enable = true;
        package = selfpkgs.niri;
      };

      programs.noctalia = {
        enable = true;
        package = selfpkgs.noctalia;

        systemd = {
          enable = true;
          target = "graphical-session.target";
        };

        recommendedServices.enable = true;
      };

      environment.systemPackages = with pkgs; [
        uwsm
        xwayland-satellite
        file-roller
        loupe
        papers
        adwaita-icon-theme
        gnome-themes-extra
        selfpkgs.fuzzel

        # browser
        brave-origin
        selfpkgs.librewolf

        # nixpak-apps
        nixpakApps.telegram
        nixpakApps.dingtalk
        nixpakApps.feishu
        nixpakApps.qq
        nixpakApps.wechat
        nixpakApps.wechat-uos
        nixpakApps.heroic

        # gaming
        mangohud
        # proton/wine
        protonplus
        winetricks

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

        # tools
        localsend
        mangohud

        # 剪贴板
        wl-clipboard
        cliphist

        # 截图
        grim
        slurp
        satty # 截图编辑标注

        file-roller # 解压工具

        nwg-look # 设置gtk主题

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
    };
}
