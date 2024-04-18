{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    apps.nicotine-plus.enable =
      lib.mkEnableOption "Enable Nicotine+ soulseek client.";
  };

  config = lib.mkIf config.apps.nicotine-plus.enable {
    environment.systemPackages = [ pkgs.nicotine-plus ];
    networking = {
      firewall.allowedTCPPortRanges = [
        # Soulseek
        {
          from = 2234;
          to = 2239;
        }
      ];
      firewall.allowedUDPPortRanges = [
        # Soulseek
        {
          from = 2234;
          to = 2239;
        }
      ];
    };
  };
}