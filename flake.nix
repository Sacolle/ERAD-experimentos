{
  description = "Flake para gerar projeto experimental e fazer o latex";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs = { self, nixpkgs }: 
      let 
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
        rEnv = pkgs.rWrapper.override {
            packages = with pkgs.rPackages; [
                languageserver
                lintr
                here
                DoE_base
                FrF2
                tidyverse
                janitor
            ];
        };
    in 
  {
        devShells.${system}.default = pkgs.mkShell { buildInputs =  [ rEnv ]; };
  };
}
