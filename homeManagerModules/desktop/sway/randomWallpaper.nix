{
  pkgs,
  lib,
  config,
  ...
}: let
  sway-randomWallpaper = pkgs.writeShellScriptBin "sway-randomWallpaper" ''
    kill `pidof swaybg`

    OLD_PIDS=()
    directory=${config.home.homeDirectory}/.local/share/backgrounds

    if [ -d "$directory" ]; then
        while true; do

          for pid in ''${OLD_PIDS[@]}; do
            kill $pid
          done
          OLD_PIDS=()

          monitor=`${config.wayland.windowManager.sway.package}/bin/swaymsg -t get_outputs -p | grep Output | awk '{print $2}'`
          
          for m in ''${monitor[@]}; do
            random_background=$(ls $directory/*.{png,jpg} | shuf -n 1)
            ${pkgs.swaybg}/bin/swaybg -o $m -i $random_background &
            OLD_PIDS+=($!)
          done

          sleep 900
        done
    fi
  '';
in {
  options = {
    alyraffauf.desktop.sway.randomWallpaper =
      lib.mkEnableOption "Enable Sway random wallpaper script.";
  };

  config = lib.mkIf config.alyraffauf.desktop.sway.randomWallpaper {
    # Packages that should be installed to the user profile.
    home.packages = with pkgs; [swaybg sway-randomWallpaper];

    wayland.windowManager.sway.config.startup = [
      {command = "${sway-randomWallpaper}/bin/sway-randomWallpaper";}
    ];
  };
}
