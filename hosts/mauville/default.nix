# Custom desktop with AMD Ryzen 5 2600, 16GB RAM, AMD Rx 6700, and 1TB SSD + 2TB HDD.
{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  archiveDirectory = "/mnt/Archive";
  domain = "raffauflabs.com";
  mediaDirectory = "/mnt/Media";
in {
  imports = [
    ../common.nix
    ./filesystems.nix
    ./home.nix
    self.inputs.nixhw.nixosModules.common-amd-cpu
    self.inputs.nixhw.nixosModules.common-amd-gpu
    self.inputs.nixhw.nixosModules.common-bluetooth
    self.inputs.nixhw.nixosModules.common-ssd
    self.inputs.raffauflabs.nixosModules.raffauflabs
  ];

  age.secrets = {
    cloudflare.file = ../../secrets/cloudflare.age;

    lastfmId = {
      owner = "navidrome";
      file = ../../secrets/lastFM/apiKey.age;
    };

    lastfmSecret = {
      owner = "navidrome";
      file = ../../secrets/lastFM/secret.age;
    };

    spotifyId = {
      owner = "navidrome";
      file = ../../secrets/spotify/clientId.age;
    };

    spotifySecret = {
      owner = "navidrome";
      file = ../../secrets/spotify/clientSecret.age;
    };

    syncthingCert.file = ../../secrets/syncthing/mauville/cert.age;
    syncthingKey.file = ../../secrets/syncthing/mauville/key.age;
  };

  boot = {
    initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "sd_mod"];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  hardware.enableAllFirmware = true;
  networking.hostName = "mauville";

  services = {
    forgejo.settings.service.DISABLE_REGISTRATION = lib.mkForce true;

    samba = {
      enable = true;
      openFirewall = true;
      securityType = "user";

      shares = {
        Media = {
          browseable = "yes";
          comment = "Media @ ${config.networking.hostName}";
          path = mediaDirectory;
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0755";
          "directory mask" = "0755";
        };

        Archive = {
          browseable = "yes";
          comment = "Archive @ ${config.networking.hostName}";
          path = archiveDirectory;
          "create mask" = "0755";
          "directory mask" = "0755";
          "guest ok" = "yes";
          "read only" = "no";
        };
      };
    };

    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };

  environment.variables.GDK_SCALE = "1.25";
  system.stateVersion = "23.11";
  zramSwap.memoryPercent = 100;

  ar = {
    apps = {
      firefox.enable = true;
      nicotine-plus.enable = true;
      podman.enable = true;
      steam.enable = true;
      virt-manager.enable = true;
    };

    desktop = {
      greetd = {
        enable = true;
        autologin = "aly";
      };

      hyprland.enable = true;
      steam.enable = true;
    };

    users = {
      aly = {
        enable = true;
        password = "$y$j9T$SHPShqI2IpRE101Ey2ry/0$0mhW1f9LbVY02ifhJlP9XVImge9HOpf23s9i1JFLIt9";

        syncthing = {
          enable = true;
          certFile = config.age.secrets.syncthingCert.path;
          keyFile = config.age.secrets.syncthingKey.path;
          musicPath = "${mediaDirectory}/Music";
        };
      };

      dustin = {
        enable = true;
        password = "$y$j9T$3mMCBnUQ.xjuPIbSof7w0.$fPtRGblPRSwRLj7TFqk1nzuNQk2oVlgvb/bE47sghl.";
      };
    };
  };

  raffauflabs = {
    inherit domain;
    enable = true;

    containers.oci = {
      audiobookshelf.enable = true;
      freshRSS.enable = true;
      plexMediaServer.enable = true;
      transmission.enable = true;
    };

    services = {
      ddclient = {
        enable = true;
        passwordFile = config.age.secrets.cloudflare.path;
        protocol = "cloudflare";
      };

      forgejo.enable = true;
      navidrome = {
        enable = true;

        lastfm = {
          idFile = config.age.secrets.lastfmId.path;
          secretFile = config.age.secrets.lastfmSecret.path;
        };

        spotify = {
          idFile = config.age.secrets.spotifyId.path;
          secretFile = config.age.secrets.spotifySecret.path;
        };
      };
    };
  };
}
