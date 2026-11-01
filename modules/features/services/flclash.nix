{ inputs, ... }:
{
  flake.nixosModules.flclash = {
    imports = [
      inputs.flclash-nix.nixosModules.flclash
    ];

    programs.flclash = {
      enable = true;
      tunMode = true;
      # owner = "you";   # 系统里只有一个 isNormalUser 账号时会自动取，不用写
    };
  };
}
