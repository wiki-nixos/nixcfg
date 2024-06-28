{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}: {
  home = {
    username = "morgan";
    homeDirectory = "/home/morgan";
    stateVersion = "24.05";
    packages = with pkgs; [
      fractal
      libreoffice-fresh
      vlc
      webcord
      xfce.xfce4-taskmanager
    ];
  };

  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "Morgan Tamayo";
      userEmail = "mrgntamayo@gmail.com";
    };
  };

  ar.home = {
    apps = {
      alacritty.enable = true;
      bash.enable = true;
      chromium.enable = true;
      firefox.enable = true;
      vsCodium.enable = true;
    };
    theme = {
      gtk = {
        name = "catppuccin-frappe-mauve-compact+normal";
        package = pkgs.catppuccin-gtk.override {
          accents = ["mauve"];
          size = "compact";
          variant = "frappe";
          tweaks = ["normal"];
        };
      };
      qt = {
        name = "Catppuccin-Frappe-Mauve";
        package = pkgs.catppuccin-kvantum.override {
          accent = "Mauve";
          variant = "Frappe";
        };
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.catppuccin-papirus-folders.override {
          flavor = "frappe";
          accent = "mauve";
        };
      };
      cursorTheme = {
        name = "Catppuccin-Frappe-Dark-Cursors";
        size = 24;
        package = pkgs.catppuccin-cursors.frappeDark;
      };
      font = {
        name = "NotoSans Nerd Font";
        size = 11;
        package = pkgs.nerdfonts.override {fonts = ["Noto"];};
      };
      terminalFont = {
        name = "NotoSansM Nerd Font";
        size = 11;
        package = pkgs.nerdfonts.override {fonts = ["Noto"];};
      };
      colors = {
        text = "#FAFAFA";
        background = "#232634";
        primary = "#CA9EE6";
        secondary = "#99D1DB";
        inactive = "#626880";
        shadow = "#1A1A1A";
      };
      wallpaper = "${config.xdg.dataHome}/backgrounds/jr-korpa-9XngoIpxcEo-unsplash.jpg";
    };
  };
}