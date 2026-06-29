{ config, pkgs, ... }:

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
      "amass"
      "ffuf"
      "httpx"
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

  environment.systemPackages = [
    pkgs.seclists
  ];
}
