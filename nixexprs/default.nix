{ system ? builtins.currentSystem }:

let
  pkgs = import <nixpkgs> { inherit system; };

  callPackage = pkgs.lib.callPackageWith (pkgs // pkgs.xlibs // self);

  self = {
    z3-everest = callPackage ./pkgs/z3-everest { };
    fstar-master = callPackage ./pkgs/fstar-master { };
    ocaml-visitors = callPackage ./pkgs/ocaml-visitors { };
    kremlin-master = callPackage ./pkgs/kremlin-master { };
  };
in
  self
