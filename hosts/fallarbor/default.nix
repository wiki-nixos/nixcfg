# Framework 13 with 11th gen Intel Core i5, 16GB RAM, 512GB SSD.
{
  config,
  lib,
  pkgs,
  self,
  ...
}: {
  imports = [
    ../common.nix
    ./disko.nix
    ./home.nix
    self.inputs.nixhw.nixosModules.framework-13-intel-11th
  ];

  age.secrets = {
    syncthingCert.file = ../../secrets/syncthing/fallarbor/cert.age;
    syncthingKey.file = ../../secrets/syncthing/fallarbor/key.age;
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  environment.variables.GDK_SCALE = "1.5";
  networking.hostName = "fallarbor";
  system.stateVersion = "24.05";

  ar = {
    apps = {
      firefox.enable = true;
      steam.enable = true;
    };

    desktop = {
      greetd.enable = true;
      hyprland.enable = true;
    };

    services.flatpak.enable = true;

    users = {
      aly = {
        enable = true;
        password = "$y$j9T$0p6rc4p5sn0LJ/6XyAGP7.$.wmTafwMMscdW1o8kqqoHJP7U8kF.4WBmzzcPYielR3";

        syncthing = {
          enable = true;
          certFile = config.age.secrets.syncthingCert.path;
          keyFile = config.age.secrets.syncthingKey.path;
          syncMusic = false;
        };
      };

      dustin = {
        enable = true;
        password = "$y$j9T$OXQYhj4IWjRJWWYsSwcqf.$lCcdq9S7m0EAdej9KMHWj9flH8K2pUb2gitNhLTlLG/";
      };
    };
  };
}
