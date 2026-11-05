{ self, ... }:
{
  flake.nixosModules.desktop =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      imports = [
        self.nixosModules.greeter
        self.nixosModules.thunar

        self.nixosModules.fcitx5
        # self.nixosModules.ibus
        self.nixosModules.desktop-pkgs
        self.nixosModules.hjem
        self.nixosModules.theme
        self.nixosModules.gaming

        self.nixosModules.i18n
        self.nixosModules.display-control
        self.nixosModules.pipewire
        self.nixosModules.power
      ];

      programs.niri = {
        enable = true;
        package = selfpkgs.niri;
      };

      programs.umbriel = {
        enable = true;
        package = selfpkgs.umbriel;
      };

      programs.noctalia = {
        enable = true;
        package = selfpkgs.noctalia;

        systemd = {
          enable = true;
          target = "graphical-session.target";
        };

        recommendedServices.enable = true;
      };

      environment.systemPackages = with pkgs; [
        uwsm
        xwayland-satellite
        file-roller
        loupe
        papers
        adwaita-icon-theme
        gnome-themes-extra
      ];
    };
}
