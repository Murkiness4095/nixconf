{
  flake.nixosModules.gaming =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.steam = {
        # Some location that should be persistent:
        #   ~/.local/share/Steam - The default Steam install location
        #   ~/.local/share/Steam/steamapps/common - The default Game install location
        #   ~/.steam/root        - A symlink to ~/.local/share/Steam
        #   ~/.steam             - Some Symlinks & user info
        enable = true;
        package = pkgs.steam;
        # https://github.com/ValveSoftware/gamescope
        # Run a GameScope driven Steam session from your display-manager
        # fix resolution upscaling and stretched aspect ratios
        gamescopeSession.enable = true;
        # https://github.com/Winetricks/winetricks
        # Whether to enable protontricks, a simple wrapper for running Winetricks commands for Proton-enabled games.
        protontricks.enable = true;
        # Whether to enable Load the extest library into Steam, to translate X11 input events to uinput events (e.g. for using Steam Input on Wayland) .
        extest.enable = true;
        fontPackages = [
          pkgs.wqy_zenhei # Need by steam for Chinese
        ];
      };

      programs.gamemode.enable = true;

      environment.systemPackages = with pkgs; [
        vulkan-loader
        vulkan-tools
      ];
    };
}
