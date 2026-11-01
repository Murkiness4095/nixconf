{
  flake.wrappers.fuzzel =
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.fuzzel ];

      config.package = pkgs.fuzzel;

      config.settings = {
        main = {
          font = "monospace:size=12";
          terminal = "${pkgs.foot}/bin/foot";
          prompt = "'❯ '";
          layer = "overlay";
        };
        colors = {
          background = "1a1b26cc";
          text = "c0caf5ff";
          match = "7aa2f7ff";
          selection = "33467cff";
          selection-text = "c0caf5ff";
          border = "7aa2f7ff";
        };
        border = {
          width = 2;
          radius = 8;
        };
      };
    };

  perSystem = { pkgs, ... }: {
    wrappers.control_type = "exclude";
  };
}
