{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    alyraffauf.containers.oci.transmission.enable =
      lib.mkEnableOption "Enable Transmission Bittorrent server.";
    alyraffauf.containers.oci.transmission.mediaDirectory = lib.mkOption {
      description = "Media directory for Transmission.";
      default = "/mnt/Media";
      type = lib.types.str;
    };
    alyraffauf.containers.oci.transmission.archiveDirectory = lib.mkOption {
      description = "Archive directory for Transmission.";
      default = "/mnt/Archive";
      type = lib.types.str;
    };
  };

  config = lib.mkIf config.alyraffauf.containers.oci.transmission.enable {
    virtualisation.oci-containers.containers = {
      transmission = {
        ports = ["0.0.0.0:9091:9091" "0.0.0.0:51413:51413"];
        image = "linuxserver/transmission:latest";
        environment = {
          PGID = "1000";
          PUID = "1000";
          TZ = "America/New_York";
        };
        volumes = [
          "transmission_config:/config"
          "${config.alyraffauf.containers.oci.transmission.mediaDirectory}:/Media"
          "${config.alyraffauf.containers.oci.transmission.archiveDirectory}:/Archive"
        ];
      };
    };
  };
}
