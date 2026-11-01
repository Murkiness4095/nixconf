{
  self,
  ...
}:
{
  flake.nixosModules.base = {
    imports = [
      self.nixosModules.fonts
      self.nixosModules.i18n
      self.nixosModules.nix-ld
      self.nixosModules.setting
      self.nixosModules.ssh
      self.nixosModules.user
      self.nixosModules.base-pkgs
    ];
  };
}
