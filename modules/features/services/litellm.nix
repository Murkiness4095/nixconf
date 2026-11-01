{
  flake.nixosModules.litellm = {
    services.litellm = {
      enable = true;
      host = "0.0.0.0";
      port = 4000;
      environment = {
        LITELLM_MASTER_KEY = "sk-litellm-local-dev-key";
      };
    };
  };
}
