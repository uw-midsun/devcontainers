{ pkgs, ... }:
pkgs.dockerTools.buildLayeredImage {
  name = "fwxvii";
  tag = "latest";

  contents = pkgs.buildEnv {
    name = "image-root";
    paths = [
      pkgs.bazel
    ];

    pathsToLink = [ "/bin" ];
  };

  config = {
    Cmd = [ "${pkgs.bashInteractive}/bin/bash" ];
    User = "midsun";
    WorkingDir = "/home/midsun";
    Env = [
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };

  fakeRootCommands = ''
    #!${pkgs.runtimeShell}
    ${pkgs.dockerTools.shadowSetup}
    groupadd -r wheel
    useradd -mg wheel midsun
    mkdir /tmp
  '';

  enableFakechroot = true;
}
