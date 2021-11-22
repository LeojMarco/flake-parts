{ config, lib, flake-modules-core-lib, ... }:
let
  inherit (lib)
    filterAttrs
    mapAttrs
    mkOption
    optionalAttrs
    types
    ;
  inherit (flake-modules-core-lib)
    mkSubmoduleOptions
    ;
in
{
  options = {
    flake = mkSubmoduleOptions {
      devShell = mkOption {
        type = types.lazyAttrsOf types.package;
        default = { };
        description = ''
          For each system a derivation that nix develop bases its environment on.
        '';
      };
    };
  };
  config = {
    flake.devShell = mapAttrs (k: v: v.devShell) config.allSystems;

    perInput = system: flake:
      optionalAttrs (flake?devShell.${system}) {
        devShell = flake.devShell.${system};
      };

    perSystem = system: { config, ... }: {
      _file = ./devShell.nix;
      options = {
        devShell = mkOption {
          type = types.package;
          default = throw "The default devShell was not configured for system ${system}. Please set it, or if you don't want to use the devShell attribute, set flake.devShell = lib.mkForce {};";
          description = ''
            A derivation that nix develop bases its environment on.
          '';
        };
      };
    };
  };
}