{
  flake.nixosModules.fcitx5 = { pkgs, ... }: {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.waylandFrontend = true;
      fcitx5.addons = with pkgs; [
        fcitx5-fluent # 主题皮肤
        fcitx5-material-color
        fcitx5-rime

        libsForQt5.fcitx5-qt
        fcitx5-gtk
      ];
    };
  };
}
