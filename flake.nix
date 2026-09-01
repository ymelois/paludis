{
  description = "paludis; multi-format package manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    eclectic = {
      url = "github:ymelois/eclectic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      eclectic,
    }:
    let
      forAllSystems = f: builtins.mapAttrs f nixpkgs.legacyPackages;
    in
    {
      packages = forAllSystems (
        system: pkgs:
        let
          cave = pkgs.stdenv.mkDerivation {
            pname = "paludis";
            version = "3.0.2";
            src = ./.;

            buildInputs = [
              eclectic.packages."${system}".default
              pkgs.cmake
              pkgs.ninja
              pkgs.gcc
              pkgs.m4
              pkgs.doxygen
              pkgs.jansson.dev
              pkgs.libarchive.dev
              pkgs.python3
              pkgs.ruby
              pkgs.boost.dev
              pkgs.file.dev
              pkgs.gtest
              pkgs.asciidoc
              pkgs.xmlto
              pkgs.html-tidy
              pkgs.docbook_xml_dtd_45
            ];

            doCheck = false;

            cmakeFlags = [
              "-DPALUDIS_CLIENTS=cave"
              "-DPALUDIS_ENVIRONMENTS=paludis;test"
              "-DPALUDIS_REPOSITORIES=default;accounts;gemcutter;repository"
              "-DPALUDIS_DEFAULT_DISTRIBUTION=exherbo"
              "-DCONFIG_FRAMEWORK=eclectic"
            ];

            postPatch = ''
              patchShebangs .
            '';

            meta = {
              mainProgram = "cave";
              license = pkgs.lib.licenses.gpl2;
            };
          };
        in
        {
          inherit cave;
          default = cave;
        }
      );

      apps = forAllSystems (
        system: pkgs:
        let
          cave = {
            type = "app";
            program = pkgs.lib.getExe self.packages.${system}.cave;
          };
        in
        {
          inherit cave;
          default = cave;
        }
      );

      devShells = forAllSystems (
        system: pkgs: {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.cave ];
          };
        }
      );
    };
}
