{ inputs, ... }:
{
  flake.nixosModules.sheng-persistence =
    { user, ... }:
    {
      imports = [
        (import "${inputs.nixos-sheng}/examples/tmpfs-root.nix" {
          inherit inputs user;
        })
      ];

      sheng.rootfs.tmpfsRoot = {
        size = "25%";
        persistHome = false;
      };

      preservation.preserveAt."/sysroot-storage" = {
        directories = [
          # Preserve root's SSH client state, not the entire root home.
          {
            directory = "/root/.ssh";
            mode = "0700";
          }
          "/var/lib/power-profiles-daemon"
          "/var/lib/upower"
          "/srv/tftp"
          {
            directory = "/var/log/journal";
            group = "systemd-journal";
            mode = "2755";
          }
        ];

        users.${user} = {
          commonMountOptions = [ "x-gvfs-hide" ];
          directories = [
            # Current config checkout; do not lose it with the volatile home.
            "Downloads"

            ".config"
            ".local/share"
            ".local/state"
            ".vscode"
            ".var"
            ".agents"
            ".codex"
            ".omp"
            ".pi"
            "Games"
            ".renpy"
            ".steam"
            ".wine"
            {
              directory = ".local/share/keyrings";
              mode = "0700";
            }
          ];
        };
      };

      # Retain boot diagnostics without unbounded persistent journal growth.
      services.journald.settings.Journal.SystemMaxUse = "256M";
    };
}
