{ self, inputs, ... }:
{
  flake.nixosModules.agents =
    {
      pkgs,
      lib,
      ...
    }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      environment.systemPackages =
        with pkgs;
        [
          chatgpt
          opencode
          inputs.omp-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
          selfpkgs.tern
          bun
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
          selfpkgs.omp-gui
        ];
    };
}
