{
  inputs,
  ...
}:
{
  flake.diskoConfigurations.M410 = {
    imports = [
      inputs.disko.nixosModules.disko
    ];
  };
}
