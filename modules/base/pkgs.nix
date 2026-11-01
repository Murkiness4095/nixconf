{
  flake.nixosModules.base-pkgs =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # base
        git
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
