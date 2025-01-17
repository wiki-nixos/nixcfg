{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.ar.home.apps.alacritty.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        colors = {
          primary = {
            background = "${config.ar.home.theme.colors.background}";
            foreground = "${config.ar.home.theme.colors.text}";
          };
          transparent_background_colors = true;
          draw_bold_text_with_bright_colors = true;
        };
        font = {
          normal = {
            family = "NotoSansM Nerd Font";
            style = "Regular";
          };
          size = config.gtk.font.size;
        };
        selection.save_to_clipboard = true;
        window = {
          blur = true;
          decorations = "Full";
          dynamic_padding = true;
          opacity = 0.8;
        };
      };
    };
  };
}
