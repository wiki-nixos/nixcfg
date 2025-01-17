self: {
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [self.homeManagerModules.default];

  home = {
    username = "dustin";
    homeDirectory = "/home/dustin";
    stateVersion = "24.05";

    packages = with pkgs; [
      fractal
      libreoffice-fresh
      plexamp
      webcord
      xfce.xfce4-taskmanager
      zoom-us
    ];
  };

  programs.home-manager.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications."application/epub+zip" = "com.calibre_ebook.calibre.desktop;org.gnome.Evince.desktop;com.calibre_ebook.calibre.ebook-viewer.desktop;";
  };

  ar.home = {
    apps = {
      alacritty.enable = true;
      bash.enable = true;
      chromium.enable = true;
      firefox.enable = true;
      vsCodium.enable = true;
    };

    defaultApps.enable = true;
    desktop.hyprland.randomWallpaper = true;

    theme = {
      enable = true;
      wallpaper = "${config.xdg.dataHome}/backgrounds/jr-korpa-9XngoIpxcEo-unsplash.jpg";
    };
  };
}
