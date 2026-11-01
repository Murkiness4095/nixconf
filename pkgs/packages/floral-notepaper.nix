# floral-notepaper.nix
# Flake-parts module for packaging Floral Notepaper from its upstream .deb.
{ lib, ... }:
let
  pname = "floral-notepaper";
  version = "1.2.0";
in
{
  perSystem =
    { pkgs, system, ... }:
    lib.mkIf (system == "x86_64-linux") {
      packages = rec {
        floral-notepaper = pkgs.stdenvNoCC.mkDerivation rec {
          inherit pname version;

          src = pkgs.fetchurl {
            url = "https://github.com/Achilng/floral-notepaper/releases/download/v${version}/floral-notepaper_${version}_amd64.deb";
            hash = "sha256-qv6EaldhsYOXCUcAp5k+UYUokC/SKvYuq2dJQ5cyGBA=";
          };

          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            dpkg
            makeWrapper
          ];

          buildInputs = with pkgs; [
            # Core GTK / WebKit dependencies provided by the host Nix store.
            gtk3
            webkitgtk_4_1
            libsoup_3
            libayatana-appindicator
            libdbusmenu
            libdbusmenu-gtk3
            gdk-pixbuf
            pango
            cairo
            harfbuzz
            fribidi
            fontconfig
            freetype
            glib
            dbus
            libepoxy
            libdrm
            libgbm
            mesa
            libGL
            libGLX
            libxkbcommon
            libx11
            libxcb
            libxcomposite
            libxcursor
            libxdamage
            libxext
            libxfixes
            libxi
            libxinerama
            libxrandr
            libxrender
            libxxf86vm
            wayland
            zlib
            expat
            libpng
            libpulseaudio
            gcc.cc.lib
            gst_all_1.gstreamer
            gst_all_1.gst-plugins-base
          ];

          unpackPhase = ''
            dpkg-deb -x $src .
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out
            cp -r usr/. $out/

            # The .deb installs the binary under usr/bin; wrap it so WebKit
            # helpers and other data files are found in the Nix store.
            mv $out/bin/${pname} $out/bin/.${pname}-wrapped
            makeWrapper $out/bin/.${pname}-wrapped $out/bin/${pname} \
              --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
              --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib" \
              --set WEBKIT_EXEC_PATH "$out/lib/x86_64-linux-gnu/webkit2gtk-4.1" \
              --set WEBKIT_INJECTED_BUNDLE_PATH "$out/lib/x86_64-linux-gnu/webkit2gtk-4.1/injected-bundle" \
              --set GSETTINGS_SCHEMA_DIR "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas" \
              --set XKB_CONFIG_ROOT "${pkgs.xkeyboard_config}/share/X11/xkb" \
              --set GST_PLUGIN_SYSTEM_PATH_1_0 "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0" \
              --set FONTCONFIG_FILE "${pkgs.fontconfig}/etc/fonts/fonts.conf"

            runHook postInstall
          '';

          meta = with lib; {
            description = "花笺 Floral Notepaper - 轻量优雅的跨平台桌面便签工具";
            homepage = "https://github.com/Achilng/floral-notepaper";
            license = licenses.mit;
            maintainers = [ ];
            platforms = [ "x86_64-linux" ];
            mainProgram = pname;
            sourceProvenance = with sourceTypes; [ binaryNativeCode ];
          };
        };

        default = floral-notepaper;
      };
    };
}
