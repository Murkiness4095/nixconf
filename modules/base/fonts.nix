{
  flake.nixosModules.fonts =
    {
      pkgs,
      ...
    }:
    {
      fonts = {
        packages = with pkgs; [
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif

          source-code-pro
          hack-font
          # jetbrains-mono

          nerd-fonts.comic-shanns-mono
          lxgw-wenkai-screen # 霞鹜文楷 屏幕阅读版

          font-awesome
          material-design-icons
          nerd-fonts.jetbrains-mono
          nerd-fonts.hack
          nerd-fonts.fira-code
          nerd-fonts.symbols-only
        ];

        # 简单配置一下 fontconfig 字体顺序，以免 fallback 到不想要的字体
        fontconfig = {
          defaultFonts = {
            emoji = [ "Noto Color Emoji" ];
            monospace = [
              "LXGW WenKai Screen"
              "ComicShannsMono Nerd Font"
              "JetBrainsMono Nerd Font"
              "Font Awesome 6 Free"
              "Material Design Icons"
              "Noto Sans Mono CJK SC"
              "Sarasa Mono SC"
              "DejaVu Sans Mono"
            ];
            sansSerif = [
              "LXGW WenKai Screen"
              "ComicShannsMono Nerd Font"
              "JetBrainsMono Nerd Font"
              "Font Awesome 6 Free"
              "Material Design Icons"
              "Noto Sans CJK SC"
              "Source Han Sans SC"
              "DejaVu Sans"
            ];
            serif = [
              "Noto Serif CJK SC"
              "Source Han Serif SC"
              "DejaVu Serif"
            ];
          };
        };
      };
    };
}
