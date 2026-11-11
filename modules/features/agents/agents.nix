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
      nixpkgs.overlays = [
        (final: prev: {
          opencode = prev.callPackage ../../../pkgs/packages/opencode-package.nix.raw { };
        })
      ];

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
