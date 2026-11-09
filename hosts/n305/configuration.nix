{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations.n305 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.node-n305
    ];
  };

  flake.nixosModules.node-n305 = { lib, pkgs, ... }: {
    imports = [
      self.nixosModules.base

      self.diskoConfigurations.n305
      self.nixosModules.preservation
      self.nixosModules.sops-nix

      self.nixosModules.zswap

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

    networking.hostName = "n305";

    networking.networkmanager = {
      enable = true;
      wifi.powersave = false;
    };

    networking.firewall = {
      enable = false;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };

    # thermald 是 Intel 官方推出的 Linux 热管理工具，能有效平滑频率波动
    services.thermald.enable = true;

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

    # Sub-Store 订阅管理器（模块导入后仍需显式启用，否则 mkIf 不产出任何配置）
    services.sub-store = {
      enable = true;
      port = 3002;
    };

    system.stateVersion = "25.05";
  };
}
