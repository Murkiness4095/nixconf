let
  theme = {
    base00 = "#111418"; # bg
    base01 = "#1a4975"; # dark
    base02 = "#989da4";
    base03 = "#eff6ff";
    base04 = "#c3c6cf";
    base05 = "#e1e2e8"; # fg
    base06 = "#eff6ff";
    base07 = "#f8fbff";
    base08 = "#ff729c"; # red
    base09 = "#ff9fbb"; # orange
    base0A = "#fff772"; # yellow
    base0B = "#7efd8f"; # green
    base0C = "#a0cafd"; # cyan
    base0D = "#86b6f0"; # blue
    base0E = "#264975"; # magenta
    base0F = "#fffaa5"; # orange
  };

  stripHash =
    str:
    if builtins.substring 0 1 str == "#" then
      builtins.substring 1 (builtins.stringLength str - 1) str
    else
      str;

  themeNoHash = builtins.mapAttrs (_: v: stripHash v) theme;
in
{
  flake = {
    inherit theme themeNoHash;
  };
}
