{
  self,
  ...
}:
{
  flake.nixosModules.core = {
    imports = [
      self.nixosModules.hjem
      # self.nixosModules.fastfetch
      # self.nixosModules.fish
      # self.nixosModules.starship
      self.nixosModules.core-pkgs
    ];
  };
}
