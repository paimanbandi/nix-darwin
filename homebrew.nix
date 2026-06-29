{
  homebrew = {
    enable = true;
    brews = [
      "cocoapods"
      "libimobiledevice"
      "usbmuxd"
      "ideviceinstaller"
      "nuclei"
      "subfinder"
      "ffuf"
      "seclists"
    ];
    casks = [
      "macfuse"
    ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}
