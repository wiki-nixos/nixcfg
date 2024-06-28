{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  home-manager = {
    sharedModules = [
      {
        ar.home = {
          desktop = {
            hyprland.autoSuspend = false;
            sway.autoSuspend = false;
          };
        };
      }
    ];
    users.aly = import ../../homes/aly;
    users.morgan = import ../../homes/morgan;
  };
}
