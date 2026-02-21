{ pkgs, ... }:
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

  python-interpreter = (pkgs.python3.withPackages (ps: python-packages));

  scons = pkgs.scons.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [python-packages];
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
      pkgs.gnugrep

      pkgs.gcc-arm-embedded-13
      pkgs.clang
      pkgs.clang-tools
      pkgs.ncurses
      pkgs.sdl2-compat
      pkgs.cpplint
      pkgs.nlohmann_json

      pkgs.pkg-config
      pkgs.autoconf
      pkgs.libtool

      scons
      python-interpreter
    ];

    pathsToLink = [ "/bin" ];
  };

  config = {
    Cmd = [ "${pkgs.bashInteractive}/bin/bash" ];
    User = "midsun";
    WorkingDir = "/home/midsun";
    Env = [
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "PYTHON=${python-interpreter}/bin/python"

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
