{
  description = "The Samsara website";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs
        {
          inherit system;
        };
    in
    rec {
      apps.default = apps.samsara-website;

      apps.samsara-website = flake-utils.lib.mkApp {
        drv = pkgs.writeShellScriptBin "serve-samsara-website.sh" ''
          ${pkgs.python3}/bin/python -m http.server \
            --bind 127.0.0.1 \
            --directory ${packages.samsara-website} \
            50333
        '';
      };

      devShells.default = devShells.samsara-website;

      devShells.samsara-website = pkgs.mkShell {
        inputsFrom = [
          packages.samsara-website
        ];
      };

      packages.default = packages.samsara-website;

      packages.samsara-website = pkgs.stdenv.mkDerivation rec {
        pname = "samsara-website";
        version = self.lastModifiedDate;
        src = self;

        buildInputs = [
          pkgs.zola
        ];

        buildPhase = ''
          zola build
        '';

        installPhase = ''
          cp -r public $out
        '';
      };
    });
}
