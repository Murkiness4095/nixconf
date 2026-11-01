{
  flake.nixosModules.display-control =
    {
      config,
      pkgs,
      ...
    }:
    {

      boot.kernelModules = [ "i2c-dev" ];
      hardware.i2c.enable = true;
      users.users.fall_dust.extraGroups = [ "i2c" ];

      environment.systemPackages = with pkgs; [
        ddcutil
        # ddcui # 如果需要图形界面
      ];
    };
}
