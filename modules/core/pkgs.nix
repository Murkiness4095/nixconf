{
  self,
  ...
}:
{
  flake.nixosModules.core-pkgs =
    { pkgs, user, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      programs.fish = {
        enable = true;
        package = selfpkgs.fish;
      };

      programs.starship = {
        enable = true;
        package = selfpkgs.starship;
      };

      users.users.${user}.shell = selfpkgs.fish;

      environment.systemPackages = with pkgs; [ ];
    };
}