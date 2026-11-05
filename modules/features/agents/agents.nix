{ self, inputs, ... }:
{
  flake.nixosModules.agents =
    {
      pkgs,
      ...
    }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      environment.systemPackages = with pkgs; [
        chatgpt
        opencode
        inputs.omp-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
        selfpkgs.tern
        selfpkgs.omp-gui
        bun
      ];
    };
}
