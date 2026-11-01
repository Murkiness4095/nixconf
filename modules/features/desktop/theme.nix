{
  flake.nixosModules.theme =
    {
      pkgs,
      user,
      ...
    }:

    let
      gtkSettings = ''
        [Settings]
        gtk-font-name=LXGW WenKai Screen 11
        gtk-theme-name=adw-gtk3-dark
        gtk-application-prefer-dark-theme=1
      '';
    in
    {
      hjem.users.${user} = {
        packages = with pkgs; [
          # GTK 主题包与字体
          adw-gtk3

          # 基础图标库
          adwaita-icon-theme
          hicolor-icon-theme
          papirus-icon-theme
          kdePackages.breeze-icons
        ];

        files = {
          # 替代原 HM 中的 gtk 属性配置
          ".config/gtk-3.0/settings.ini".text = gtkSettings;
          ".config/gtk-4.0/settings.ini".text = gtkSettings;
        };
      };
    };
}
