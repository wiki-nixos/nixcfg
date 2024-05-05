{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  home-manager.users.aly = {
    imports = [../../homeManagerModules ../../aly.nix];

    alyraffauf.services.easyeffects = {
      enable = true;
      preset = "framework13";
    };
  };
}
