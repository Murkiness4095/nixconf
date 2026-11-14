{
  flake.nixosModules.gtk =
    { pkgs, ... }:
    let
      # GTK 从 $XDG_CONFIG_DIRS（默认 /etc/xdg）读取，系统级即可生效。
      gtkSettings = ''
        [Settings]
        gtk-font-name=LXGW WenKai Screen 11
        gtk-theme-name=adw-gtk3-dark
        gtk-application-prefer-dark-theme=1
      '';
    in
    {
      environment.systemPackages = with pkgs; [
        # GTK 主题包与字体
        adw-gtk3

        # 基础图标库
        adwaita-icon-theme
        hicolor-icon-theme
        papirus-icon-theme
        kdePackages.breeze-icons
      ];

      environment.etc."xdg/gtk-3.0/settings.ini".text = gtkSettings;
      environment.etc."xdg/gtk-4.0/settings.ini".text = gtkSettings;
    };
}
