{
  homebrew = {
    enable = true;
    brews = [
      "cocoapods"
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
