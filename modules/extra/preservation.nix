{ inputs, ... }:
{
  flake.nixosModules.preservation =
    { user, ... }:
    {
      imports = [
        inputs.preservation.nixosModules.default
      ];

      preservation = {
        enable = true;

        preserveAt."/persist" = {
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
            "/etc/nixos"
          ];

          files = [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
          ];

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

              ".agents"
              ".codex"
              ".omp"
              ".pi"

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
    };
}