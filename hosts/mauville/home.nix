{
  config,
  lib,
  pkgs,
  self,
  ...
}: {
  home-manager = {
    sharedModules = [
      {
        xdg.userDirs.music = "/mnt/Media/Music";
        ar.home.desktop.hyprland.autoSuspend = false;
      }
    ];

    users.aly = lib.mkForce {
      imports = [self.homeManagerModules.aly];
      systemd.user = {
        services = {
          backblaze-sync = {
            Unit.Description = "Backup to Backblaze.";

            Service.ExecStart = "${pkgs.writeShellScript "backblaze-sync" ''
              declare -A backups
              backups=(
                ['/home/aly/pics/camera']="b2://aly-camera"
                ['/home/aly/sync']="b2://aly-sync"
                ['/mnt/Archive/Archive']="b2://aly-archive"
                ['/mnt/Media/Audiobooks']="b2://aly-audiobooks"
                ['/mnt/Media/Music']="b2://aly-music"
              )
              # Recursively backup folders to B2 with sanity checks.
              for folder in "''${!backups[@]}"; do
                if [ -d "$folder" ] && [ "$(ls -A "$folder")" ]; then
                  ${lib.getExe pkgs.backblaze-b2} sync --delete $folder ''${backups[$folder]}
                else
                  echo "$folder does not exist or is empty."
                  exit 1
                fi
              done
            ''}";
          };

          build-hosts = {
            Unit.Description = "Build nixosConfiguration for each host.";

            Service.ExecStart = "${pkgs.writeShellScript "build-hosts" ''
              hosts=(
                fallarbor
                lavaridge
                petalburg
                rustboro
              )

              for h in "''${hosts[@]}"; do
                nix build github:alyraffauf/nixcfg#nixosConfigurations.$h.config.system.build.toplevel --json | ${lib.getExe pkgs.jq} -r '.[].outputs | to_entries[].value' | ${lib.getExe' pkgs.cachix "cachix"} push alyraffauf
              done
            ''}";
          };
        };

        timers = {
          backblaze-sync = {
            Install.WantedBy = ["timers.target"];
            Timer.OnCalendar = "*-*-* 03:00:00";
            Unit.Description = "Daily backups to Backblaze.";
          };
          build-hosts = {
            Install.WantedBy = ["timers.target"];
            Timer.OnCalendar = "*-*-* 06:00:00";
            Unit.Description = "Build hosts daily.";
          };
        };
      };
    };
  };
}
