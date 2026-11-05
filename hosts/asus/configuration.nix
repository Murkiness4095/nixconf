{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations.asus = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.node-asus
    ];
  };

  flake.nixosModules.node-asus =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        self.nixosModules.base
        self.nixosModules.desktop

        # hardware
        self.nixosModules.asusctl
        self.nixosModules.nvidia
        self.nixosModules.pipewire
        self.nixosModules.power
        self.nixosModules.zswap

        self.diskoConfigurations.asus
        self.nixosModules.preservation
        self.nixosModules.sops-nix

        # agents
        self.nixosModules.agents

        # services
        self.nixosModules.adguardhome
        self.nixosModules.podman
        # self.nixosModules.litellm

        # proxy
        # self.nixosModules.honk-core
        self.nixosModules.mihomo
        # self.nixosModules.sing-box
        self.nixosModules.sub-store
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

      networking.hostName = "asus";

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
        hashedPassword = "$6$4W.SQiUcbZlEzn27$7mJVzEWZWtwRELuR/VBImj2hDUQTFMo3ZkMZ4yI4YQ9hlDqPXwslAASB7fmauTAfi3Cnj08Zz0N2yBlVCu9Hb0";

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

      my.nvidia = {
        enable = true;
        open = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable; # 可选
      };

      # Sub-Store 订阅管理器（模块导入后仍需显式启用，否则 mkIf 不产出任何配置）
      services.sub-store = {
        enable = true;
        port = 3002;
      };

      fileSystems."/mnt/data" = {
        device = "/dev/disk/by-uuid/31fcdaf7-ef08-4782-a498-bb2aeb51dc17";
        fsType = "btrfs";
        options = [
          "nofail"
          "x-gvfs-show"
        ];
      };

      fileSystems."/mnt/Games" = {
        device = "/dev/disk/by-uuid/3C900EF3900EB404";
        fsType = "ntfs";
        options = [
          "uid=1000"
          "gid=100"
          "fmask=0022"
          "dmask=0022"
          "rw"
          "exec"
          "nofail"
          "x-gvfs-show"
        ];
      };

      system.stateVersion = "25.05";
    };
}
