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

      environment.persistence."/persist" = {
        allowTrash = true;
        hideMounts = true;
        directories = [
          "/var/log"
          "/var/lib"
          "/var/lib/bluetooth"
          "/var/lib/flatpak"
          "/var/lib/nixos"
          "/var/lib/systemd"
          "/etc/NetworkManager/system-connections"
          "/etc/asusd"
          "/etc/honk"
          "/etc/libvirt"
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
