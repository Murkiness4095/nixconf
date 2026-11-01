{
  inputs,
  self,
  ...
}:
{
  flake.darwinConfigurations.deMac-mini = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      self.darwinModules.node-deMac-mini
    ];
  };

  flake.darwinModules.node-deMac-mini = { pkgs, ... }: {
    imports = [
      self.darwinModules.base
    ];
  };
}
