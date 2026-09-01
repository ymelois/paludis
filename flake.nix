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
    inputs:
    let
      mkPaludis =
        system: pkgs:
        pkgs.stdenv.mkDerivation {
          pname = "paludis";
          version = "3.0.2";
          src = ./.;

          buildInputs = [
            inputs.eclectic.packages."${system}".default
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
      packages = builtins.mapAttrs (system: pkgs: {
        default = mkPaludis system pkgs;
        paludis = mkPaludis system pkgs;
      }) inputs.nixpkgs.legacyPackages;

      app = builtins.mapAttrs (system: pkgs: {
        default = mkPaludis system pkgs;
        paludis = mkPaludis system pkgs;
      }) inputs.nixpkgs.legacyPackages;

      devShells = builtins.mapAttrs (system: pkgs: {
        default = pkgs.mkShell {
          inputsFrom = [ (mkPaludis system pkgs) ];
        };
      }) inputs.nixpkgs.legacyPackages;
    };
}
