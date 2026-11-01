{
  flake.nixosModules.user =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.my.base.user;
    in
    {
      options.my.base.user = {
        enable = lib.mkEnableOption "primary user configuration";

        name = lib.mkOption {
          type = lib.types.str;
          default = "fall_dust";
          description = "Primary user name for this host";
        };

        hashedPassword = lib.mkOption {
          type = lib.types.str;
          default = "$6$4W.SQiUcbZlEzn27$7mJVzEWZWtwRELuR/VBImj2hDUQTFMo3ZkMZ4yI4YQ9hlDqPXwslAASB7fmauTAfi3Cnj08Zz0N2yBlVCu9Hb0";
        };

        extraGroups = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "wheel"
            "networkmanager"
            "video"
            "render"
            "input"
            "podman"
            "libvirtd"
            "kvm"
          ];
        };

        keys = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpr2d4l3Qr9w0DK/jgVPBnCWfT9rPYnBNFr6Rw/86ov"
          ];
        };

        rootKeys = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpr2d4l3Qr9w0DK/jgVPBnCWfT9rPYnBNFr6Rw/86ov"
          ];
        };
      };

      config = lib.mkMerge [
        {
          # 核心逻辑：这里导出 user 传递给其他 NixOS 模块（如你的 hjem 模块）
          _module.args.user = cfg.name;
        }
        (lib.mkIf cfg.enable {
          users.mutableUsers = false;
          security.sudo.wheelNeedsPassword = false;

          users.users.${cfg.name} = {
            isNormalUser = true;
            hashedPassword = cfg.hashedPassword;
            extraGroups = cfg.extraGroups;
            openssh.authorizedKeys.keys = cfg.keys;
          };

          users.users.root = {
            openssh.authorizedKeys.keys = cfg.rootKeys;
          };
        })
      ];
    };
}
