{
  flake.nixosModules.thunar = # File Manager
    { pkgs, ... }:

    {
      # 文件管理器
      programs.thunar = {
        enable = true;
        plugins = with pkgs; [
          thunar-volman
          thunar-archive-plugin
        ];
      };

      # 声明式配置 Thunar 右键自定义动作 (System-wide)
      environment.etc."xdg/Thunar/uca.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <actions>
          <action>
            <icon>tab-new</icon>
            <name>在新标签页打开</name>
            <unique-id>nixos-new-tab-custom</unique-id>
            <command>thunar --new-tab %f</command>
            <description>在当前窗口的新标签页中打开文件夹</description>
            <range></range>
            <patterns>*</patterns>
            <directories/>
          </action>
          <action>
            <icon>utilities-terminal</icon>
            <name>在此处打开终端</name>
            <unique-id>nixos-open-term-custom</unique-id>
            <command>alacritty --working-directory %f</command>
            <description>在当前目录打开终端</description>
            <range></range>
            <patterns>*</patterns>
            <directories/>
          </action>
        </actions>
      '';

      # gparted 需要 polkit 提权执行分区操作
      security.polkit.enable = true;

      # 给文件管理器提供预览缩略图的服务
      services.tumbler.enable = true;

      # polkit agent
      security.soteria.enable = true;

      # 磁盘挂载
      services.gvfs.enable = true;
    };
}
