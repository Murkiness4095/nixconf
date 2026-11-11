{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations.M410 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.node-M410
    ];
  };

  flake.nixosModules.node-M410 =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      imports = [
        self.nixosModules.base

        self.nixosModules.sops-nix

        self.nixosModules.fcitx5
        # self.nixosModules.desktop-pkgs
        # self.nixosModules.system-pkgs
        self.nixosModules.alacritty
        self.nixosModules.kitty
        self.nixosModules.theme
        self.nixosModules.vscode
        self.nixosModules.zed

        self.nixosModules.i18n
        self.nixosModules.display-control
        self.nixosModules.pipewire
        self.nixosModules.power
        self.nixosModules.zswap

        # proxy
        # self.nixosModules.mihomo
      ];

      boot.kernelPackages = pkgs.linuxPackages_latest;
      # boot.kernelPackages = pkgs.linuxPackages_testing;
      # boot.kernelPackages = pkgs.linuxPackages_zen;

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # do not need to keep too much generations
      boot.loader.systemd-boot.configurationLimit = 10;
      # boot.loader.grub.configurationLimit = 10;

      networking.hostName = "M410";

      networking.networkmanager = {
        enable = true;
        wifi.powersave = false;
      };

      networking.firewall = {
        enable = false;
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
      };

      # --- 开启自定义模块 ---
      my.base.user = {
        enable = true;
        name = "fall_dust";
        hashedPassword = "$6$D9EQAhIc1xne1uz6$csErETsAo7JmxD2eRPTvaMFv0AJ0FLu6qBhDXU7a3IGPsc7zlHnl/nSy7HmoHKYp/wwdwvcT1BcPLo4zvQhRj1";

        extraGroups = [
          "wheel"
          "networkmanager"
          "input"
          "podman"
          "libvirtd"
          "kvm"
        ];

        keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpr2d4l3Qr9w0DK/jgVPBnCWfT9rPYnBNFr6Rw/86ov"
        ];

        rootKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpr2d4l3Qr9w0DK/jgVPBnCWfT9rPYnBNFr6Rw/86ov"
        ];
      };

      # Set your time zone.
      # time.timeZone = "Europe/Amsterdam";

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Select internationalisation properties.
      # i18n.defaultLocale = "en_US.UTF-8";
      # console = {
      #   font = "Lat2-Terminus16";
      #   keyMap = "us";
      #   useXkbConfig = true; # use xkb.options in tty.
      # };

      # Enable the X11 windowing system.
      services.xserver.enable = true;
      services.displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
        autoLogin = {
          enable = true;
          user = "fall_dust";
        };
      };
      services.desktopManager.plasma6.enable = true;

      services.flatpak.enable = true;

      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      # gparted 需要 polkit 提权执行分区操作
      security.polkit.enable = true;

      environment.systemPackages = with pkgs; [
        # browser
        selfpkgs.brave-origin
        selfpkgs.librewolf

        # chat
        telegram-desktop
        selfpkgs.aerion
        selfpkgs.qq
        selfpkgs.wechat

        # download
        varia
        motrix
        qbittorrent-enhanced
        yt-dlp

        # media
        kazumi
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
        selfpkgs.meatshell

        # 剪贴板
        wl-clipboard
        cliphist

        # gaming
        heroic
        hmcl
        selfpkgs.hyprism
        mangohud
        # proton/wine
        protonplus
        umu-launcher
        protontricks
        winetricks

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
        warehouse

        nwg-look # 设置gtk主题

        # Vibe Coding
        mcp-nixos
        omp

        # Web3.0/Crypto
        selfpkgs.onekey-wallet

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

      # Configure keymap in X11
      # services.xserver.xkb.layout = "us";
      # services.xserver.xkb.options = "eurosign:e,caps:escape";

      # Enable CUPS to print documents.
      # services.printing.enable = true;

      # Enable sound.
      # services.pulseaudio.enable = true;
      # OR
      # services.pipewire = {
      #   enable = true;
      #   pulse.enable = true;
      # };

      # Enable touchpad support (enabled default in most desktopManager).
      # services.libinput.enable = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      # users.users.fall_dust = {
      #   isNormalUser = true;
      #   initialPassword = "passwd";
      #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      #   packages = with pkgs; [
      #     tree
      #   ];
      # };

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      # List services that you want to enable:

      # Enable the OpenSSH daemon.
      # services.openssh.enable = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      # Copy the NixOS configuration file and link it from the resulting system
      # (/run/current-system/configuration.nix). This is useful in case you
      # accidentally delete configuration.nix.
      # system.copySystemConfiguration = true;

      # This option defines the first version of NixOS you have installed on this particular machine,
      # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
      #
      # Most users should NEVER change this value after the initial install, for any reason,
      # even if you've upgraded your system to a new NixOS release.
      #
      # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
      # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
      # to actually do that.
      #
      # This value being lower than the current NixOS release does NOT mean your system is
      # out of date, out of support, or vulnerable.
      #
      # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
      # and migrated your data accordingly.
      #
      # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
      system.stateVersion = "26.05"; # Did you read the comment?

    };
}
