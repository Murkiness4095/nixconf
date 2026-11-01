{
  flake.nixosModules.setting = {
    # 垃圾回收策略
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };

    nix.settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      accept-flake-config = true;
      trusted-users = [ "fall_dust" ];
      builders-use-substitutes = true;
    };
  };
}
