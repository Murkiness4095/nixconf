{
  flake.nixosModules.zswap = {
    boot.zswap = {
      enable = true;
      maxPoolPercent = 20;
      compressor = "zstd";
      shrinkerEnabled = true;
      acceptThresholdPercent = 90;
    };
  };
}
