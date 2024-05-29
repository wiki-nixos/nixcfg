{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    alyraffauf.desktop.hyprland.enable =
      lib.mkEnableOption "Hyprland wayland compositor.";
  };

  config = lib.mkIf config.alyraffauf.desktop.hyprland.enable {
    alyraffauf.desktop.waylandComp.enable = lib.mkDefault true;

    programs = {
      hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      };
    };
  };
}
