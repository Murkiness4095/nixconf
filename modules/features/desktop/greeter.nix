{
  flake.nixosModules.greeter = { pkgs, ... }: {
    # noctalia-greeter
    services.displayManager.noctalia-greeter = {
      enable = true;

      settings = {
        cursor.size = 24;
        keyboard.layout = "us";
      };

      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
      };
    };
  };
}
