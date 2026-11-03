{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations.acer = inputs.nixpkgs.lib.nixosSystem {
    imports = [
      self.nixosModules.node-acer
    ];
  };

  flake.nixosModules.node-acer = { lib, pkgs, ... }: {
    imports = [
      self.nixosModules.base
        # self.nixosModules.core
      # self.nixosModules.desktop

      # self.diskoConfigurations.acer
      # self.nixosModules.impermanence

      # proxy
      self.nixosModules.mihomo
      # self.nixosModules.sing-box

    ];

    networking.hostName = "acer";

    swapDevices = lib.mkForce [
      {
        device = "/persist/var/lib/swapfile";
        size = 8 * 1024;
      }
    ];

    system.stateVersion = "25.05";
  };
}
