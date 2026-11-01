{
  inputs,
  ...
}:
{
  flake.diskoConfigurations.asus = {
    imports = [
      inputs.disko.nixosModules.disko
    ];

    disko.devices = {
      # 内存 tmpfs 根目录 (Impermanence 临时根目录)
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "size=25%"
          "mode=755"
        ];
      };

      disk.main = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };

            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "discard=async"
                    ];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "discard=async"
                    ];
                  };
                };
              };
            };

            # Physical swap
            swap = {
              size = "32G";
              type = "8200";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
          };
        };
      };
    };

    # Impermanence 必须的挂载标志：确保 /persist 在开机阶段优先挂载，以便获取持久化密钥与配置
    fileSystems."/persist".neededForBoot = true;
  };
}
