{ self, ... }:
{
  flake.nixosModules.base-pkgs =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      environment.systemPackages = with pkgs; [
        # base
        selfpkgs.git
        vim
        wget
        curl

        just

        atftp # 或者 tftp-hpa

        whois
        lshw
        smartmontools
        parted
        dmidecode
        nix-ld
        tree
        icu

        sops
      ];
    };
}