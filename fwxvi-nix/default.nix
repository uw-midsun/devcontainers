{pkgs, ...}:
let
  python-packages = with pkgs.python3Packages; [
        autopep8
        pylint
        python-can
        cantools
        jinja2
        pyyaml
        pyserial
        sv-ttk
        pandas
  ];

  scons = pkgs.scons.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ python-packages;
  });
in
pkgs.dockerTools.buildLayeredImage {
  name = "fwxvi-nix";
  tag = "latest";

  contents = pkgs.buildEnv {
    name = "image-root";
    paths = [
      pkgs.bashInteractive
      pkgs.coreutils
      pkgs.curl
      pkgs.wget
      pkgs.vim
      pkgs.git

      pkgs.gcc-arm-embedded-13
      pkgs.clang
      pkgs.clang-tools
      pkgs.ncurses
      pkgs.sdl2-compat
      pkgs.cpplint
      pkgs.nlohmann_json

      scons

      (pkgs.python3.withPackages(ps: python-packages))
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
