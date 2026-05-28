{
  description = "A flake for building circom-compat (ark-circom) ffi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }: 
    let
      stableSystems = [
        "x86_64-linux" "aarch64-linux"
        "x86_64-darwin" "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs stableSystems;
      # crates.io's WAF returns 403 for the default `curl/X.Y.Z` User-Agent.
      fetchurlUserAgentOverlay = final: prev: {
        fetchurl = args: prev.fetchurl (args // {
          curlOptsList = (args.curlOptsList or []) ++ [ "-A" "logos-storage-nix" ];
        });
      };
      pkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ fetchurlUserAgentOverlay ];
      });
    in
    {
      packages = forAllSystems (system: let
        pkgs = pkgsFor.${system};
      in {
        default = pkgs.callPackage ./default.nix {};
      });
    };
}