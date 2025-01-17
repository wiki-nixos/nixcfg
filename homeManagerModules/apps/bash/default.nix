{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.ar.home.apps.bash.enable {
    home.shellAliases = {
      cat = lib.getExe pkgs.bat;
      grep = lib.getExe config.programs.ripgrep.package;
    };

    programs = {
      bash = {
        enable = true;
        enableCompletion = true;
        enableVteIntegration = true;

        shellOptions = [
          "autocd"
          "cdspell"
          "checkjobs"
          "checkwinsize"
          "dirspell"
          "dotglob"
          "extglob"
          "globstar"
          "histappend"
        ];

        initExtra = ''
          export PS1="[\[$(tput setaf 27)\]\u\[$(tput setaf 135)\]@\[$(tput setaf 45)\]\h:\[$(tput setaf 33)\]\w] \[$(tput sgr0)\]$ "
        '';
      };

      eza = {
        enable = true;
        extraOptions = ["--group-directories-first" "--header"];
        git = true;
        icons = true;
      };

      fzf = {
        enable = true;
        tmux.enableShellIntegration = true;
      };

      ripgrep = {
        enable = true;
        arguments = ["--pretty"];
      };
    };
  };
}
