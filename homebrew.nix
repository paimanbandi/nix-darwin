{
  homebrew = {
    enable = true;
    brews = [
      "cocoapods"
      "libimobiledevice"
      "usbmuxd"
      "ideviceinstaller"
      "nuclei"
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
