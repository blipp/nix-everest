{ stdenv, lib, pkgs, fetchFromGitHub, ocamlPackages, makeWrapper, z3-everest, fstar-master, ocaml-visitors }:

stdenv.mkDerivation rec {
  name = "kremlin-master-${version}";
  version = "0.9.6.0";

#  src = /home/volhovm/code/kremlin;

  src = fetchFromGitHub {
    owner = "FStarLang";
    repo = "kremlin";
    rev = "8e2499453d4abf04996147b735157eb4c62088b5";
    sha256 = "0c60sgj6zwhpc2djm9wh2dz1h6n0kpx6cjf13si4qjx9w5knmbdf";
    fetchSubmodules = false;
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = with ocamlPackages; [
    z3-everest fstar-master
    ocaml-visitors # TODO this will be available in next version of NixOS
    ocaml findlib batteries menhir stdint
    zarith camlp4 yojson pprint
    ulex ocaml-migrate-parsetree process ppx_deriving ppx_deriving_yojson ocamlbuild
    fix wasm
  ];

  makeFlags = [ "PREFIX=$(out)"
                "FSTAR_HOME=${fstar-master}"
                "KREMLIN_HOME=${src}"
              ];

  preBuild = ''
    # This is used by the 'install' target of kremlin
    mkdir -p $out/share/kremlin/misc; cp -r misc/* $out/share/kremlin/misc/

    # Hacl* (and possibly other programs) need this. It would bette be in share/ too
    # but everest infrastructure will assume exactly this path in many other 
    # places (like Hacl* makefiles).
    mkdir -p $out/include; cp -r misc/* $out/include/
    mkdir -p $out/kremlib; cp -r misc/* $out/kremlib/ # maybe put it under include too?
  '';
  # into the 'out' (i'm not sure which way is better @volhovm)
  postInstall = ''
    wrapProgram $out/bin/krml --set FSTAR_HOME "${fstar-master}" --set KREMLIN_HOME "${src}"
  '';

  meta = with stdenv.lib; {
    description = "KreMLin is a tool for extracting low-level F* programs to readable C code";
    homepage = https://fstarlang.github.io/lowstar/html/;
    license = licenses.asl20;
    platforms = with platforms; darwin ++ linux;
    maintainers = [ "Benjamin Lipp <blipp@mailbox.org>" ];
  };
}
