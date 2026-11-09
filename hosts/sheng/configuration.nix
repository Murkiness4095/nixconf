{
  inputs,
  self,
  lib,
  ...
}:
{
  flake.nixosConfigurations.sheng = inputs.nixos-sheng.lib.shengSystem {
    modules = [ self.nixosModules.node-sheng ];
  };

  flake.nixosModules.node-sheng = { ... }: {
    # Add architecture-independent modules from your own configuration here.
    # The shengSystem constructor already imports the complete board support.
    imports = [
      self.nixosModules.base
      self.nixosModules.desktop-sheng
      self.nixosModules.pipewire
      self.nixosModules.power
      self.nixosModules.zram

      self.nixosModules.sheng-persistence
      self.nixosModules.sops-nix

      self.nixosModules.mihomo
    ];
    # 当前是双系统，必须保留 linux 根分区。
    sheng.rootfs.partlabel = "linux";

    # 控制 U-Boot 菜单保留的系统世代数量。
    sheng.boot.configurationLimit = 10;

    # USB-connected deep suspend woke early; s2idle passed timed wake tests.
    # Host-specific candidate; this is suspend-to-RAM and does not need swap.
    boot.kernelParams = [ "mem_sleep_default=s2idle" ];

    # This tablet has no backing swap device; zswap requires one.
    # zramSwap.enable = true;

    networking.hostName = "sheng";
    networking.networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    networking.firewall = {
      enable = false;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
    services.shengSerialConsole.enable = true;

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

    users.mutableUsers = lib.mkForce false;

    system.stateVersion = "26.11";
  };
}
