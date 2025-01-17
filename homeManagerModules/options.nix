{
  config,
  lib,
  osConfig,
  pkgs,
  self,
  ...
}: let
  cfg = config.ar.home;
in {
  options.ar.home = {
    apps = {
      alacritty.enable = lib.mkEnableOption "Alacritty terminal.";
      bash.enable = lib.mkEnableOption "Bash defaults.";

      chromium = {
        enable = lib.mkEnableOption "Chromium-based browser with default extensions.";
        package = lib.mkPackageOption pkgs "brave" {};
      };

      emacs.enable = lib.mkEnableOption "Emacs text editor.";
      fastfetch.enable = lib.mkEnableOption "Fastfetch.";
      firefox.enable = lib.mkEnableOption "Firefox web browser.";
      fuzzel.enable = lib.mkEnableOption "Fuzzel app launcher.";

      keepassxc = {
        enable = lib.mkEnableOption "KeePassXC password manager.";

        settings = lib.mkOption {
          description = "KeePassXC settings.";
          default = {};
          type = lib.types.attrs;
        };
      };

      librewolf.enable = lib.mkEnableOption "Librewolf web browser.";
      mako.enable = lib.mkEnableOption "Mako notification daemon.";

      nemo.enable = lib.mkOption {
        description = "Cinnamon Nemo file manager.";
        default = cfg.defaultApps.fileManager == pkgs.cinnamon.nemo;
        type = lib.types.bool;
      };

      swaylock.enable = lib.mkEnableOption "Swaylock screen locker.";
      thunar.enable = lib.mkOption {
        description = "Thunar file manager.";
        default = cfg.defaultApps.fileManager == pkgs.xfce.thunar;
        type = lib.types.bool;
      };

      tmux.enable = lib.mkEnableOption "Tmux shell session manager.";
      vsCodium.enable = lib.mkEnableOption "VSCodium text editor.";
      waybar.enable = lib.mkEnableOption "Waybar wayland panel.";
      wlogout.enable = lib.mkEnableOption "Wlogout session prompt.";
    };

    defaultApps = {
      enable = lib.mkEnableOption "Declaratively set default apps and file associations.";
      audioPlayer = lib.mkPackageOption pkgs "audio player" {default = ["celluloid"];};
      editor = lib.mkPackageOption pkgs "text editor" {default = ["vscodium"];};
      fileManager = lib.mkPackageOption pkgs "file manager" {default = ["cinnamon" "nemo"];};
      imageViewer = lib.mkPackageOption pkgs "image viewer" {default = ["gnome" "eog"];};
      pdfViewer = lib.mkPackageOption pkgs "pdf viewer" {default = ["evince"];};
      terminal = lib.mkPackageOption pkgs "terminal emulator" {default = ["alacritty"];};
      terminalEditor = lib.mkPackageOption pkgs "terminal text editor" {default = ["vim"];};
      videoPlayer = lib.mkPackageOption pkgs "video player" {default = ["celluloid"];};
      webBrowser = lib.mkPackageOption pkgs "web browser" {default = ["firefox"];};
    };

    desktop = {
      cinnamon.enable = lib.mkOption {
        description = "Cinnamon with sane defaults";
        default = osConfig.ar.desktop.cinnamon.enable;
        type = lib.types.bool;
      };

      gnome.enable = lib.mkOption {
        description = "GNOME with sane defaults.";
        default = osConfig.ar.desktop.gnome.enable;
        type = lib.types.bool;
      };

      hyprland = {
        enable = lib.mkOption {
          description = "Hyprland with full desktop session components.";
          default = osConfig.ar.desktop.hyprland.enable;
          type = lib.types.bool;
        };

        autoSuspend = lib.mkOption {
          description = "Whether to autosuspend on idle.";
          default = cfg.desktop.hyprland.enable;
          type = lib.types.bool;
        };

        randomWallpaper = lib.mkOption {
          description = "Whether to enable random wallpaper script.";
          default = cfg.desktop.hyprland.enable;
          type = lib.types.bool;
        };

        redShift = lib.mkOption {
          description = "Whether to redshift display colors at night.";
          default = cfg.desktop.hyprland.enable;
          type = lib.types.bool;
        };

        tabletMode = {
          enable = lib.mkEnableOption "Tablet mode for hyprland.";

          autoRotate = lib.mkOption {
            description = "Whether to autorotate screen.";
            default = cfg.desktop.hyprland.tabletMode.enable;
            type = lib.types.bool;
          };

          menuButton = lib.mkOption {
            description = "Whether to add menu button for waybar.";
            default = cfg.desktop.hyprland.tabletMode.enable;
            type = lib.types.bool;
          };

          virtKeyboard = lib.mkOption {
            description = "Whether to enable dynamic virtual keyboard.";
            default = cfg.desktop.hyprland.tabletMode.enable;
            type = lib.types.bool;
          };
        };
      };

      sway = {
        enable = lib.mkOption {
          description = "Sway with full desktop session components.";
          default = osConfig.ar.desktop.sway.enable;
          type = lib.types.bool;
        };

        autoSuspend = lib.mkOption {
          description = "Whether to autosuspend on idle.";
          default = cfg.desktop.sway.enable;
          type = lib.types.bool;
        };

        randomWallpaper = lib.mkOption {
          description = "Whether to enable random wallpaper script.";
          default = cfg.desktop.sway.enable;
          type = lib.types.bool;
        };

        redShift = lib.mkOption {
          description = "Whether to redshift display colors at night.";
          default = cfg.desktop.sway.enable;
          type = lib.types.bool;
        };
      };
    };

    services = {
      mpd = {
        enable = lib.mkEnableOption "MPD user service.";

        musicDirectory = lib.mkOption {
          description = "Name of music directory";
          default = config.xdg.userDirs.music;
          type = lib.types.str;
        };
      };

      easyeffects = {
        enable = lib.mkEnableOption "EasyEffects user service.";

        preset = lib.mkOption {
          description = "Name of preset to start with.";
          default = "";
          type = lib.types.str;
        };
      };
    };

    theme = {
      enable = lib.mkEnableOption "Gtk, Qt, and application colors.";

      darkMode = lib.mkOption {
        description = "Whether to prefer dark mode apps or not.";
        default = cfg.theme.enable;
        type = lib.types.bool;
      };

      colors = {
        text = lib.mkOption {
          description = "Text color.";
          default = "#FFFFFF";
          type = lib.types.str;
        };

        background = lib.mkOption {
          description = "Background color.";
          default = "#242424";
          type = lib.types.str;
        };

        primary = lib.mkOption {
          description = "Primary color.";
          default = "#78AEED"; #"#CA9EE6";
          type = lib.types.str;
        };

        secondary = lib.mkOption {
          description = "Secondary color.";
          default = "#CA9EE6"; #"#99D1DB";
          type = lib.types.str;
        };

        inactive = lib.mkOption {
          description = "Inactive color.";
          default = "#242424";
          type = lib.types.str;
        };

        shadow = lib.mkOption {
          description = "Drop shadow color.";
          default = "#1A1A1A";
          type = lib.types.str;
        };
      };

      gtk.hideTitleBar = lib.mkOption {
        description = "Whether to hide GTK3/4 titlebars (useful for some window managers).";
        default = false;
        type = lib.types.bool;
      };

      wallpaper = lib.mkOption {
        description = "Default wallpaper.";
        default = "${config.xdg.dataHome}/backgrounds/jr-korpa-9XngoIpxcEo-unsplash.jpg";
        type = lib.types.str;
      };
    };
  };
}
