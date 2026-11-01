{
  flake.nixosModules.ibus = { pkgs, ... }: {
    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus.waylandFrontend = true;
      ibus.engines = with pkgs.ibus-engines; [
        # (rime.override {
        #   rimeDataPkgs = [
        #     pkgs.rime-ice
        #   ];
        # })

        rime
      ];
    };
  };
}
