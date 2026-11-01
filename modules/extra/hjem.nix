{
  inputs,
  ...
}:
{
  flake.nixosModules.hjem = { user, ... }: {
    imports = [
      inputs.hjem.nixosModules.default
    ];

    hjem.users.${user} = {
      user = user; # this is the name of the user
      directory = "/home/${user}"; # where the user's $HOME resides
      clobberFiles = true;
    };
  };
}
