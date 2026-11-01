{
  flake.nixosModules.ssh =
    {
      lib,
      pkgs,
      ...
    }:
    {
      # Or disable the firewall altogether.
      networking.firewall.enable = lib.mkDefault false;
      # Enable the OpenSSH daemon.
      services.openssh = {
        enable = true;
        hostKeys = [
          {
            path = "/persist/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
        settings = {
          X11Forwarding = true;
          # root user is used for remote deployment, so we need to allow it
          PermitRootLogin = "prohibit-password";
          PasswordAuthentication = false; # disable password login
        };
        openFirewall = true;
      };

      # tftp
      services.atftpd = {
        enable = true;
        root = "/srv/tftp";
      };

      # Add terminfo database of all known terminals to the system profile.
      # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/config/terminfo.nix
      # environment.enableAllTerminfo = true;
      environment.systemPackages = with pkgs; [
        ncurses # 包含常见 terminfo
      ];
    };
}
