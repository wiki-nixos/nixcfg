{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  imports = [./firefox ./nicotine-plus ./steam ./podman ./virt-manager];
}
