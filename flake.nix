{
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://ccicnce113424.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ccicnce113424.cachix.org-1:OWV4fSkx7o7TinVCSD98zPG8udShCIjhyaAdOIRNetw="
    ];
  };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    ccicnce113424.url = "github:ccicnce113424/nix-packages";
    disko.url = "github:nix-community/disko/latest";
    impermanence.url = "github:nix-community/impermanence";
    preservation.url = "github:nix-community/preservation";
    nix-gaming.url = "github:fufexan/nix-gaming";
    omp-nix.url = "github:yuxqiu/omp-nix";
    sops-nix.url = "github:Mic92/sops-nix";
    wrapper-modules.url = "github:nix-community/nix-wrapper-modules";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nixpak-apps = {
      url = "github:Murkiness4095/nixpak-apps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Import all .nix files from current directory except flake.nix recursively
  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      inherit (lib.fileset) toList fileFilter;

      isNixModule = file: file.hasExt "nix" && file.name != "flake.nix" && !lib.hasPrefix "_" file.name;

      importTree = path: toList (fileFilter isNixModule path);

      mkFlake = inputs.flake-parts.lib.mkFlake { inherit inputs; };
    in
    mkFlake { imports = importTree ./.; };
}
