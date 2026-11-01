{
  flake.nixosModules.mihomo =
    {
      config,
      pkgs,
      ...
    }:
    {
      sops.secrets.mihomo-config = {
        sopsFile = ../../../secrets/config.yaml;
        key = "";
      };

      services.mihomo = {
        enable = true;
        tunMode = true;
        webui = pkgs.zashboard;
        configFile = config.sops.secrets.mihomo-config.path;
      };
    };
}
