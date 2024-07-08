# Lenovo Thinkpad T440p with a Core i5 4210M, 16GB RAM, 512GB SSD.
{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}: {
  imports = [
    ../common.nix
    ./disko.nix
    ./home.nix
    inputs.nixhw.nixosModules.thinkpad-t440p
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  environment.variables.GDK_SCALE = "1.25";
  networking.hostName = "rustboro";
  system.stateVersion = "24.05";
  zramSwap.memoryPercent = 100;

  ar = {
    apps.firefox.enable = true;

    desktop = {
      greetd = {
        enable = true;

        autologin = {
          enable = true;
          user = "aly";
        };
      };

      hyprland.enable = true;
    };

    services.syncthing.enable = true;

    users.aly = {
      enable = true;
      password = "$y$j9T$VdtiEyMOegHpcUwgmCVFD0$K8Ne6.zk//VJNq2zxVQ0xE0Wg3LohvAQd3Xm9aXdM15";
    };
  };
}
