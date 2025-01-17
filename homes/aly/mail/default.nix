{
  config,
  lib,
  pkgs,
  ...
}: let
  mkPassword = secret: "${lib.getExe' pkgs.coreutils "cat"} ${secret}";
in {
  age.secrets = {
    achacegaGmail.file = ../../../secrets/mail/achacega_gmail.age;
    alyraffaufFastmail.file = ../../../secrets/mail/alyraffauf_fastmail.age;
  };

  accounts.email.accounts = {
    "alyraffauf@fastmail.com" = {
      address = "alyraffauf@fastmail.com";
      aliases = ["aly@raffauflabs.com"];
      flavor = "fastmail.com";
      himalaya.enable = true;
      passwordCommand = mkPassword config.age.secrets.alyraffaufFastmail.path;
      primary = true;
      realName = "Aly Raffauf";

      signature = {
        text = ''
          Thank you,
          Aly Raffauf
          https://aly.RaffaufLabs.com
          https://alyraffauf.github.com
        '';

        showSignature = "append";
      };

      thunderbird = {
        enable = true;
        profiles = ["default"];
      };

      userName = "alyraffauf@fastmail.com";
    };

    "achacega@gmail.com" = {
      address = "achacega@gmail.com";
      aliases = ["alyraffauf@gmail.com"];
      flavor = "gmail.com";
      himalaya.enable = true;
      passwordCommand = mkPassword config.age.secrets.achacegaGmail.path;
      realName = "Aly Raffauf";

      signature = {
        text = ''
          --
          Aly Raffauf (née Chace)
        '';

        showSignature = "append";
      };

      thunderbird = {
        enable = true;
        profiles = ["default"];
      };

      userName = "achacega@gmail.com";
    };

    "aly.chace@joingsg.com" = {
      address = "aly.chace@joingsg.com";
      flavor = "gmail.com";
      realName = "Aly Raffauf";

      signature = {
        text = ''
          Aly Raffauf (née Chace)
          Content Operations Specialist 1
          Global Savings Group
        '';

        showSignature = "append";
      };

      thunderbird = {
        enable = true;
        profiles = ["work"];
      };

      userName = "aly.chace@joingsg.com";
    };
  };

  home.file = let
    source = builtins.fetchGit {
      url = "https://github.com/rafaelmardojai/thunderbird-gnome-theme.git";
      rev = "65d5c03fc9172d549a3ea72fd366d544981a002b";
      ref = "main";
    };
  in {
    ".thunderbird/default/chrome".source = source;
    ".thunderbird/work/chrome".source = source;
  };

  programs = {
    himalaya.enable = true;

    thunderbird = {
      enable = true;
      profiles = let
        settings = {
          "calendar.timezone.useSystemTimezone" = true;
          "datareporting.healthreport.uploadEnabled" = false;
          "mailnews.default_sort_order" = 2; # descending, 1 for ascending
          "mailnews.default_sort_type" = 18; # sort by date
          "mailnews.message_display.disable_remote_image" = false;
          "network.cookie.cookieBehavior" = 2; # no cookies
          "pdfjs.enabledCache.state" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.fingerprintingProtection" = true;
          "privacy.firstparty.isolate" = true;
          "privacy.purge_trackers.date_in_cookie_database" = "0";
          "privacy.resistFingerprinting" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "svg.context-properties.content.enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "toolkit.telemetry.enabled" = false;
        };
      in {
        default = {
          inherit settings;
          isDefault = true;
        };
        work.settings = settings;
      };
    };
  };

  xdg.desktopEntries.thunderwork = {
    categories = ["Application" "Network" "Chat" "Email" "Feed" "GTK" "News"];
    comment = "Read and write e-mails or RSS feeds, or manage tasks on calendars.";
    exec = "thunderbird -P work --name thunderwork %U";
    genericName = "Email Client";
    icon = "thunderbird";
    mimeType = ["message/rfc822" "x-scheme-handler/mailto" "text/calendar" "text/x-vcard"];
    name = "Thunderbird (work)";
    settings.StartupWMClass = "thunderwork";
    startupNotify = true;
    terminal = false;
  };
}
