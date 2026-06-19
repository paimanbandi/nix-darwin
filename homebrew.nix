{
  homebrew = {
    enable = true;
    brews = [
      "cocoapods"
      "libimobiledevice"
      "usbmuxd"
      "ideviceinstaller"
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
