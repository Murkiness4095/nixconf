{
  inputs,
  ...
}:
{
  flake.nixosModules.impermanence =
    { user, ... }:
    {
      imports = [
        inputs.impermanence.nixosModules.impermanence
      ];

      # ---------------------------------------------------------------------------
      # Impermanence 持久化绑定规则 (所有的 fileSystems 均已交由 disko.nix 自动生成)
      # ---------------------------------------------------------------------------
      environment.persistence."/persist" = {
        allowTrash = true;
        hideMounts = true;
        directories = [
          "/var/log"
          "/var/lib"
          "/var/lib/bluetooth"
          "/var/lib/flatpak"
          # "/var/lib/mihomo"
          "/var/lib/nixos"
          "/var/lib/systemd"
          # "/var/cache/tuigreet" # 记忆 tuigreet 上次登录用户名和 Session
          "/etc/NetworkManager/system-connections" # 保存的 Wi-Fi 与网络配置
          "/etc/asusd" # 华硕 asusd 风扇/电源控制服务配置
          # "/etc/daed" # daed 运行配置
          "/etc/honk"
          "/etc/libvirt" # KVM 虚拟机定义与虚拟网络配置
        ];
        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ];

        # 用户目录持久化（由系统层级统一管理，共享 hideMounts = true）
        users.${user} = {
          directories = [
            "Desktop"
            "Documents"
            "Downloads"
            "Music"
            "Pictures"
            "Public"
            "Templates"
            "Videos"

            ".config"
            ".local/share"
            ".local/state"
            ".ssh"
            ".android"
            ".vscode"
            ".var"

            # agent
            ".agents"
            ".codex"
            ".omp"
            ".pi"

            # Games
            "Games"
            ".renpy"
            ".minecraft"
            ".hmcl"
            ".steam"
            ".wine"
          ];

          files = [
            ".cache/fuzzel"
          ];
        };
      };
    };
}
