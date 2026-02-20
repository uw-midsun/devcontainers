{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs =
    inputs@{ ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;
      buildNixpkgs =
        system:
        import inputs.nixpkgs {
          inherit system;
          overlays = [ ];
        };
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = buildNixpkgs system;
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              dive
              nixfmt-tree
            ];
          };
        }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = buildNixpkgs system;
        in
        rec {
          default = fwxvi-nix;
          fwxvi-nix = pkgs.callPackage ./fwxvi-nix { };
        }
      );
    };
}
