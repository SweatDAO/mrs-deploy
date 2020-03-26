{ pkgsSrc ? (import ./nix/pkgs.nix {}).pkgsSrc
, pkgs ? (import ./nix/pkgs.nix { inherit pkgsSrc; }).pkgs
, doCheck ? false
}: with pkgs;

let
  inherit (callPackage ./nix/dapp.nix {}) specs package;

  this = package (specs.this // {
    name = "mrs-deploy";
    inherit doCheck;
    solcFlags = "--metadata";
  });

  this-optimize = package (specs.this // {
    name = "mrs-deploy-optimized";
    inherit doCheck;
    solcFlags = "--optimize --metadata";
  });

  mkScripts = { regex, name, solidityPackages }: makerScriptPackage {
    inherit name solidityPackages;
    src = lib.sourceByRegex ./bin (regex ++ [ ".*lib.*" ]);
    extraBins = [ git ];
    scriptEnv = {
      SKIP_BUILD = true;
    };
  };

  optimized = mkScripts {
    name = "mrs-deploy-optimized";
    regex = [ "deploy-core" ];
    solidityPackages = [ this-optimize ];
  };

  nonOptimized = mkScripts {
    name = "mrs-deploy";
    regex = [ "deploy-fab" "deploy-ilk.*" ];
    solidityPackages = [ this ];
  };
in symlinkJoin {
  name = "mrs-deploy-both";
  paths = [ optimized nonOptimized ];
}
