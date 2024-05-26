{
  description = "Nix rebuild script flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem ( system: 
      let pkgs = import nixpkgs { inherit system; }; in
        {
          packages.default = 
            pkgs.writeShellScriptBin "nix-rebuilder" ( builtins.readFile ./src/nix-rebuilder.bash ); 
        }
    );
}
