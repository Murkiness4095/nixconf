{
  flake.nixosModules.pipewire = {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    services.speechd.enable = true;

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
