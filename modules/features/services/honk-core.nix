{ inputs, ... }:
{
  flake.nixosModules.honk-core = {
    imports = [
      inputs.ccicnce113424.nixosModules.honk-core
    ];

    nixpkgs.overlays = [
      inputs.ccicnce113424.overlays.default
    ];

    services.honk-core = {
      enable = true;

      doona = {
        enable = true;
        listenAddress = "0.0.0.0";
        port = 9527;
        openFirewall = true;
      };
    };
  };
}
