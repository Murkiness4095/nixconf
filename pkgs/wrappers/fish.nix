{
  flake.wrappers.fish =
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        wlib.modules.default
        wlib.modules.constructFiles
      ];

      config.package = pkgs.fish;

      config.constructFiles.config = {
        relPath = "fish/config.fish";
        content = ''
          if status is-interactive
            set -g fish_greeting

            fish_add_path -g -p ~/.config/guix/current/bin ~/.guix-profile/bin

            set -gx GUIX_PROFILE "$HOME/.guix-profile"
            if test -f "$GUIX_PROFILE/etc/profile"
              set -gx SSL_CERT_DIR "$GUIX_PROFILE/etc/ssl/certs"
              set -gx SSL_CERT_FILE "$GUIX_PROFILE/etc/ssl/certs/ca-certificates.crt"
              set -gx GIT_SSL_CAINFO "$GUIX_PROFILE/etc/ssl/certs/ca-certificates.crt"
            end

            if type -q starship
              starship init fish | source
            end
          end
        '';
      };

      config.runShell = [
        ''mkdir -p "$HOME/.config/fish"''
        ''cp -f ${config.constructFiles.config.path} "$HOME/.config/fish/config.fish"''
      ];
      config.passthru.shellPath = pkgs.fish.passthru.shellPath;
    };
  perSystem = { pkgs, ... }: {
    wrappers.control_type = "exclude";
  };
}
