{...}: {
  programs.yarn = {
    enable = true;
    settings = {
      # Privacy: disable telemetry (only setting that transmits externally)
      enableTelemetry = false;

      # Supply chain: don't install versions published in the last 3 days
      npmMinimalAgeGate = "3d";

      # Belt-and-suspenders — pin secure defaults explicitly
      checksumBehavior = "throw";
      enableScripts = false;
      enableStrictSettings = true;
      enableStrictSsl = true;
    };
  };
}
