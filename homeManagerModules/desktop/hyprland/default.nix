{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.alyraffauf.desktop.hyprland.enable {
    wayland.windowManager.hyprland.enable = true;

    wayland.windowManager.hyprland.extraConfig = let
      modifier = "SUPER";

      # Hyprland desktop utilities
      hyprnome = lib.getExe pkgs.hyprnome;
      hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";

      # Default apps
      defaultApps = {
        browser = config.alyraffauf.defaultApps.webBrowser.exe;
        editor = config.alyraffauf.defaultApps.editor.exe;
        fileManager = lib.getExe pkgs.xfce.thunar;
        launcher = lib.getExe pkgs.fuzzel;
        lock = lib.getExe pkgs.swaylock;
        logout = lib.getExe pkgs.wlogout;
        passwordManager = lib.getExe' pkgs.keepassxc "keepassxc";
        terminal = config.alyraffauf.defaultApps.terminal.exe;
        virtKeyboard = lib.getExe' pkgs.squeekboard "squeekboard";
      };

      wallpaperd =
        if config.alyraffauf.desktop.hyprland.randomWallpaper
        then
          pkgs.writeShellScript "hyprland-randomWallpaper" ''
            OLD_PIDS=()
            directory=${config.home.homeDirectory}/.local/share/backgrounds

            if [ -d "$directory" ]; then
                while true; do
                  NEW_PIDS=()
                  monitor=`${config.wayland.windowManager.hyprland.package}/bin/hyprctl monitors | grep Monitor | awk '{print $2}'`
                  for m in ''${monitor[@]}; do
                    random_background=$(ls $directory/*.{png,jpg} | shuf -n 1)
                    ${lib.getExe pkgs.swaybg} -o $m -i $random_background -m fill &
                    NEW_PIDS+=($!)
                  done

                  if [ ''${OLD_PIDS[@]} -gt 0 ]; then
                    sleep 5
                    for pid in ''${OLD_PIDS[@]}; do
                      kill $pid
                    done
                  fi

                  OLD_PIDS=$NEW_PIDS
                  sleep 895
                done
            fi
          ''
        else "${lib.getExe pkgs.swaybg} -i ${config.alyraffauf.theme.wallpaper}";

      startupApps =
        [
          wallpaperd
          (lib.getExe pkgs.waybar)
          "${defaultApps.fileManager} --daemon"
          idled
          (lib.getExe' pkgs.blueman "blueman-applet")
          (lib.getExe' pkgs.networkmanagerapplet "nm-applet")
          (lib.getExe' pkgs.playerctl "playerctld")
          (lib.getExe' pkgs.swayosd "swayosd-server")
          (lib.getExe pkgs.mako)
          "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1"
        ]
        ++ lib.lists.optionals (config.alyraffauf.desktop.hyprland.redShift) [
          "${pkgs.geoclue2}/libexec/geoclue-2.0/demos/agent"
          (lib.getExe pkgs.gammastep)
        ];

      screenshot = rec {
        bin = lib.getExe pkgs.hyprshot;
        folder = "${config.xdg.userDirs.pictures}/screenshots";
        screen = "${bin} -m output -o ${folder}";
        region = "${bin} -m region -o ${folder}";
      };

      windowManagerBinds = {
        down = "d";
        left = "l";
        right = "r";
        up = "u";
        h = "l";
        j = "d";
        k = "u";
        l = "r";
      };

      defaultWorkspaces = [1 2 3 4 5 6 7 8 9];

      laptopMonitors = {
        framework = "desc:BOE 0x095F,preferred,auto,1.6";
        t440p = "desc:LG Display 0x0569,preferred,auto,1.0";
        yoga9i = "desc:Samsung Display Corp. 0x4152,preferred,auto,2,transform,0";
      };

      externalMonitors = {
        homeOffice0 = "desc:LG Electronics LG ULTRAWIDE 311NTAB5M720,preferred,auto,1.25,vrr,2";
        homeOffice1 = "desc:LG Electronics LG IPS QHD 109NTWG4Y865,preferred,-2560x0,auto";
        homeOffice3 = "desc:LG Electronics LG ULTRAWIDE 207NTHM9F673, preferred,auto,1.25,vrr,2";
        homeOffice4 = "desc:LG Electronics LG IPS QHD 207NTVSE5615,preferred,-1152x0,1.25,transform,1";
        workShop = "desc:Guangxi Century Innovation Display Electronics Co. Ltd 27C1U-D 0000000000001,preferred,-2400x0,1.6";
        weWork = "desc:HP Inc. HP 24mh 3CM037248S,preferred,-1920x0,auto";
      };

      gdk_scale = "1.5";

      clamshell = pkgs.writeShellScript "hyprland-clamshell" ''
        NUM_MONITORS=$(${hyprctl} monitors all | grep Monitor | wc --lines)
        if [ "$1" == "on" ]; then
          if [ $NUM_MONITORS -gt 1 ]; then
            ${hyprctl} keyword monitor "eDP-1, disable"
          fi
        elif [ "$1" == "off" ]; then
          ${
          lib.strings.concatStringsSep "\n"
          (
            lib.attrsets.mapAttrsToList (name: monitor: ''${hyprctl} keyword monitor "${monitor}"'')
            laptopMonitors
          )
        }
        fi
      '';

      tablet = pkgs.writeShellScript "hyprland-tablet" ''
        STATE=`${lib.getExe pkgs.dconf} read /org/gnome/desktop/a11y/applications/screen-keyboard-enabled`

        if [ $STATE -z ] || [ $STATE == "false" ]; then
          if ! [ `pgrep -f ${defaultApps.virtKeyboard}` ]; then
            ${defaultApps.virtKeyboard} &
          fi
          ${lib.getExe pkgs.dconf} write /org/gnome/desktop/a11y/applications/screen-keyboard-enabled true
        elif [ $STATE == "true" ]; then
          ${lib.getExe pkgs.dconf} write /org/gnome/desktop/a11y/applications/screen-keyboard-enabled false
        fi
      '';

      # Media/hardware commands
      brightness = rec {
        bin = lib.getExe' pkgs.swayosd "swayosd-client";
        up = "${bin} --brightness=raise";
        down = "${bin} --brightness=lower";
      };

      volume = rec {
        bin = lib.getExe' pkgs.swayosd "swayosd-client";
        up = "${bin} --output-volume=raise";
        down = "${bin} --output-volume=lower";
        mute = "${bin} --output-volume=mute-toggle";
        micMute = "${bin} --input-volume=mute-toggle";
      };

      media = rec {
        bin = lib.getExe pkgs.playerctl;
        play = "${bin} play-pause";
        paus = "${bin} pause";
        next = "${bin} next";
        prev = "${bin} previous";
      };

      idled = pkgs.writeShellScript "hyprland-idled" ''
        ${lib.getExe pkgs.swayidle} -w \
          before-sleep '${media.paus}' \
          before-sleep '${defaultApps.lock}' \
          timeout 240 '${lib.getExe pkgs.brightnessctl} -s set 10' \
            resume '${lib.getExe pkgs.brightnessctl} -r' \
          timeout 300 '${defaultApps.lock}' \
          timeout 330 '${hyprctl} dispatch dpms off' \
            resume '${hyprctl} dispatch dpms on' \
          ${
          if config.alyraffauf.desktop.hyprland.autoSuspend
          then ''timeout 900 'sleep 2 && ${lib.getExe' pkgs.systemd "systemctl"} suspend' \''
          else ''\''
        }
      '';
    in ''
        ${
        lib.strings.concatStringsSep "\n"
        (
          lib.attrsets.mapAttrsToList (name: value: "monitor = ${value}")
          (laptopMonitors // externalMonitors)
        )
      }
        monitor = ,preferred,auto,auto

        # Turn off the internal display when lid is closed.
        bindl=,switch:on:Lid Switch,exec,${clamshell} on
        bindl=,switch:off:Lid Switch,exec,${clamshell} off

        # Enable virtual keyboard in tablet mode
        bindl=,switch:Lenovo Yoga Tablet Mode Control switch,exec,${tablet}

        # unscale XWayland apps
        xwayland {
          force_zero_scaling = true
        }

        # toolkit-specific scale
        env = GDK_SCALE,${gdk_scale}

        # Some default env vars.
        env = XCURSOR_SIZE,${toString config.alyraffauf.theme.cursorTheme.size}
        env = QT_QPA_PLATFORMTHEME,qt6ct

        # Execute necessary apps
        ${
        lib.strings.concatMapStringsSep
        "\n"
        (x: "exec-once = ${x}")
        startupApps
      }

        # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
        input {
          kb_layout = us
          kb_variant = altgr-intl
          follow_mouse = 1
          sensitivity = 0 # -1.0 to 1.0, 0 means no modification.
          touchpad {
            clickfinger_behavior = true
            drag_lock = true
            middle_button_emulation = true
            natural_scroll = yes
            tap-to-click = true
          }
        }

        gestures {
          workspace_swipe = true
          workspace_swipe_touch = true
        }

        general {
          gaps_in = 5
          gaps_out = 6
          border_size = 2
          col.active_border = rgba(${lib.strings.removePrefix "#" config.alyraffauf.theme.colors.secondary}EE) rgba(${lib.strings.removePrefix "#" config.alyraffauf.theme.colors.primary}EE) 45deg
          col.inactive_border = rgba(${lib.strings.removePrefix "#" config.alyraffauf.theme.colors.inactive}AA)

          layout = dwindle

          allow_tearing = false
        }

        decoration {
          rounding = 10
          blur {
            enabled = true
            size = 8
            passes = 1
          }
          drop_shadow = yes
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(${lib.strings.removePrefix "#" config.alyraffauf.theme.colors.shadow}EE)

          dim_special = 0.5

          # Window-specific rules
          layerrule = blur, waybar
          layerrule = ignorezero, waybar
          layerrule = blur, launcher
          layerrule = blur, notifications
          layerrule = ignorezero, notifications
          layerrule = blur, logout_dialog
          layerrule = blur, swayosd
          layerrule = ignorezero, swayosd
        }

        animations {
          enabled = yes
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05

          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = specialWorkspace, 1, 6, default, slidevert
          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = workspaces, 1, 6, default
        }

        dwindle {
          preserve_split = yes
        }

        master {
          always_center_master = true
          new_is_master = false
        }

        misc {
          disable_hyprland_logo = true
          disable_splash_rendering = true
          focus_on_activate = true
          vfr = true
        }

        # Window Rules
        ${
        lib.strings.concatMapStringsSep "\n"
        (x: ''
          windowrulev2 = center(1),class:(${x})
          windowrulev2 = float,class:(${x})
          windowrulev2 = size 40% 60%,class:(${x}})
        '')
        [
          ".blueman-manager-wrapped"
          "blueberry.py"
          "com.github.wwmm.easyeffects"
          "pavucontrol"
        ]
      }

        windowrulev2 = center(1),class:(org.keepassxc.KeePassXC)
        windowrulev2 = float,class:(org.keepassxc.KeePassXC)
        windowrulev2 = size 80% 80%,class:(org.keepassxc.KeePassXC)

        windowrulev2 = float, class:^(firefox)$, title:^(Picture-in-Picture)$
        windowrulev2 = move 70% 20%, class:^(firefox)$, title:^(Picture-in-Picture)$
        windowrulev2 = pin,   class:^(firefox)$, title:^(Picture-in-Picture)$

        windowrulev2 = suppressevent maximize, class:.*

        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        bind = ${modifier}, B, exec, ${defaultApps.browser}
        bind = ${modifier}, E, exec, ${defaultApps.editor}
        bind = ${modifier}, F, exec, ${defaultApps.fileManager}
        bind = ${modifier}, P, exec, ${defaultApps.passwordManager}
        bind = ${modifier}, R, exec, ${defaultApps.launcher}
        bind = ${modifier}, T, exec, ${defaultApps.terminal}

        # Manage session.
        bind = ${modifier}, C, killactive,
        bind = ${modifier} CONTROL, L, exec, ${defaultApps.lock}
        bind = ${modifier}, M, exec, ${defaultApps.logout}

        # Basic window management.
        bind = ${modifier} SHIFT, W, fullscreen
        bind = ${modifier} SHIFT, V, togglefloating,
        # bind = ${modifier} SHIFT, P, pseudo, # dwindle
        bind = ${modifier} SHIFT, backslash, togglesplit, # dwindle

        # Move focus with mainMod + keys ++
        # Move window with mainMod SHIFT + keys ++
        # Move workspace to another output with mainMod CONTROL SHIFT + keys.
        ${
        lib.strings.concatStringsSep "\n"
        (
          lib.attrsets.mapAttrsToList (key: direction: ''
            bind = ${modifier}, ${key}, movefocus, ${direction}
            bind = ${modifier} SHIFT, ${key}, movewindow, ${direction}
            bind = ${modifier} CONTROL SHIFT, ${key}, movecurrentworkspacetomonitor, ${direction}
          '')
          windowManagerBinds
        )
      }

        # Gnome-like workspaces.
        bind = ${modifier}, comma, exec, ${hyprnome} --previous
        bind = ${modifier}, period, exec, ${hyprnome}
        bind = ${modifier} SHIFT, comma, exec, ${hyprnome} --previous --move
        bind = ${modifier} SHIFT, period, exec, ${hyprnome} --move

        # Switch workspaces with mainMod + [1-9] ++
        # Move active window to a workspace with mainMod + SHIFT + [1-9].
      ${
        lib.strings.concatMapStringsSep "\n"
        (x: ''
          bind = ${modifier}, ${toString x}, workspace, ${toString x}
          bind = ${modifier} SHIFT, ${toString x}, movetoworkspace, ${toString x}
        '')
        defaultWorkspaces
      }

        # Scratchpad show and move
        bind = ${modifier}, S, togglespecialworkspace, magic
        bind = ${modifier} SHIFT, S, movetoworkspace, special:magic

        # Scroll through existing workspaces with mainMod + scroll
        bind = ${modifier}, mouse_down, workspace, +1
        bind = ${modifier}, mouse_up, workspace, -1

        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = ${modifier}, mouse:272, movewindow
        bindm = ${modifier}, mouse:273, resizewindow

        # Display, volume, microphone, and media keys.
        bindle = , xf86monbrightnessup, exec, ${brightness.up}
        bindle = , xf86monbrightnessdown, exec, ${brightness.down}
        bindle = , xf86audioraisevolume, exec, ${volume.up};
        bindle = , xf86audiolowervolume, exec, ${volume.down};
        bindl = , xf86audiomute, exec, ${volume.mute}
        bindl = , xf86audiomicmute, exec, ${volume.micMute}
        bindl = , xf86audioplay, exec, ${media.play}
        bindl = , xf86audioprev, exec, ${media.prev}
        bindl = , xf86audionext, exec, ${media.next}

        # Extra bindings for petalburg.
        bind = , xf86launch4, exec, pp-adjuster
        bind = , xf86launch2, exec, ${media.play}

        # Screenshot with hyprshot.
        bind = , PRINT, exec, ${screenshot.screen}
        bind = ${modifier}, PRINT, exec, ${screenshot.region}

        # Show/hide waybar.
        bind = ${modifier}, F11, exec, pkill -SIGUSR1 waybar

        bind=CTRL ALT,R,submap,resize
        submap=resize
          binde=,down,resizeactive,0 10
          binde=,left,resizeactive,-10 0
          binde=,right,resizeactive,10 0
          binde=,up,resizeactive,0 -10
          bind=,escape,submap,reset
        submap=reset

        bind=CTRL ALT,M,submap,move
        submap=move
          # Move window with keys ++
          # Move workspaces across monitors with CONTROL + keys.
        ${
        lib.strings.concatStringsSep "\n"
        (
          lib.attrsets.mapAttrsToList (key: direction: ''
            bind = , ${key}, movewindow, ${direction}
            bind = CONTROL, ${key}, movecurrentworkspacetomonitor, ${direction}
          '')
          windowManagerBinds
        )
      }

        # Move active window to a workspace with [1-9]
        ${
        lib.strings.concatMapStringsSep "\n"
        (x: "bind = , ${toString x}, movetoworkspace, ${toString x}")
        defaultWorkspaces
      }

          # hyprnome
          bind = , comma, exec, ${hyprnome} --previous --move
          bind = , period, exec, ${hyprnome} --move
          bind=,escape,submap,reset
        submap=reset
    '';
  };
}
