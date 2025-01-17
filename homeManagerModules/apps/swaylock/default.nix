{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.ar.home.apps.swaylock.enable {
    home.packages = with pkgs; [swaylock];

    programs.swaylock.enable = true;

    xdg.configFile."swaylock/config".text = ''
      bs-hl-color=e78284
      caps-lock-bs-hl-color=e78284
      caps-lock-key-hl-color=e78284
      color=303446
      daemonize
      font="NotoSansMNerdFont-Regular"
      image=${config.ar.home.theme.wallpaper}
      indicator-caps-lock
      indicator-idle-visible
      indicator-radius=120
      indicator-thickness=20
      inside-caps-lock-color=303446cc
      inside-clear-color=303446cc
      inside-color=303446cc
      inside-ver-color=303446cc
      inside-wrong-color=303446cc
      key-hl-color=a6d189
      line-caps-lock-color=${config.ar.home.theme.colors.background}CC
      line-clear-color=${config.ar.home.theme.colors.background}CC
      line-color=${config.ar.home.theme.colors.background}CC
      line-ver-color=${config.ar.home.theme.colors.background}CC
      line-wrong-color=${config.ar.home.theme.colors.background}CC
      ring-caps-lock-color=e78284cc
      ring-clear-color=85c1dccc
      ring-color=${config.ar.home.theme.colors.primary}CC
      ring-ver-color=a6d189cc
      ring-wrong-color=e78284cc
      separator-color=${config.ar.home.theme.colors.background}CC
      text-caps-lock-color=c6d0f5
      text-clear-color=c6d0f5
      text-ver-color=c6d0f5
      text-wrong-color=c6d0f5
    '';
  };
}
