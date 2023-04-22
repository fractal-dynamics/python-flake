{
  description = "Python application flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    mach-nix.url = "github:davhau/mach-nix";
    pypi-deps-db = {
      url = "github:davhau/pypi-deps-db/0f67e6ea7384cea09f7dedbc7a69710b22da7cf2";
      flake = false;
    };
    mach-nix.inputs.pypi-deps-db.follows = "pypi-deps-db";
  };

  outputs = {
    self,
    nixpkgs,
    mach-nix,
    flake-utils,
    ...
  }: let
    pythonVersion = "python310";
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        mach = mach-nix.lib.${system};

        pythonApp =
          mach.buildPythonApplication
          {
            src = ./.;
            requirementsExtra = "requests";
          };
        pythonAppEnv = mach.mkPython {
          python = pythonVersion;
          requirements = builtins.readFile ./requirements.txt;
        };
        pythonAppImage = pkgs.dockerTools.buildLayeredImage {
          name = pythonApp.pname;
          contents = [pythonApp];
          config.Cmd = ["${pythonApp}/bin/main"];
        };
      in rec
      {
        packages = {
          image = pythonAppImage;

          pythonPkg = pythonApp;
          default = packages.pythonPkg;
        };

        apps.default = {
          type = "app";
          program = "${packages.pythonPkg}/bin/main";
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = [pythonAppEnv];

          shellHook = ''
            export PYTHONPATH="${pythonAppEnv}/bin/python"
          '';
        };
      }
    );
}
