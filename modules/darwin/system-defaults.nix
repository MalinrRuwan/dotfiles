{
  # macOS system defaults managed by nixmac.

  system.defaults.ActivityMonitor = {
    OpenMainWindow = false;
  };
  system.defaults.NSGlobalDomain = {
    "com.apple.sound.beep.feedback" = 0;
    "com.apple.sound.beep.volume" = 1.0;
    "com.apple.trackpad.scaling" = 0.875;
    AppleInterfaceStyleSwitchesAutomatically = true;
    AppleShowScrollBars = "Always";
    InitialKeyRepeat = 30;
    KeyRepeat = 2;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
  };
  system.defaults.WindowManager = {
    AppWindowGroupingBehavior = true;
    EnableTiledWindowMargins = false;
  };
  system.defaults.dock = {
    autohide-delay = 0.0;
    largesize = 66;
    magnification = true;
    show-recents = false;
    tilesize = 46;
    wvous-br-corner = 4;
  };
  system.defaults.finder = {
    FXDefaultSearchScope = "SCcf";
    FXPreferredViewStyle = "Nlsv";
    ShowPathbar = true;
  };
  system.defaults.hitoolbox = {
    AppleFnUsageType = "Change Input Source";
  };
  system.defaults.magicmouse = {
    MouseButtonMode = "OneButton";
  };}
