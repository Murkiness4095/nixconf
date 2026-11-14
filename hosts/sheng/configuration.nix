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

    # 平板上的 Steam 是 arm64 客户端，FHS 环境仍依赖 gtk2，而 nixpkgs 已把
    # gtk2 标记为 broken（27.05 移除）。shengSystem 直接传入现成的 pkgs，
    # 其内部 nixpkgs.config 会被忽略，所以单独用带 handler 的 pkgs 实例包一层。
    programs.steam-aarch64.package =
      (import inputs.nixpkgs {
        system = "aarch64-linux";
        config = {
          allowUnfree = true;
          problems.handlers."gtk+".broken = "warn";
        };
      }).callPackage "${inputs.steam-aarch64}/package.nix" { };

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
