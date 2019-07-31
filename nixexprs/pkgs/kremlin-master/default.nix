{ stdenv, lib, pkgs, fetchFromGitHub, ocamlPackages, makeWrapper, z3-everest, fstar-master, ocaml-visitors }:

stdenv.mkDerivation rec {
  name = "kremlin-master-${version}";
  version = "0.9.6.0";

#  src = /home/volhovm/code/kremlin;

  src = fetchFromGitHub {
    owner = "FStarLang";
    repo = "kremlin";
    rev = "086a6d419484e2173483d995c4b2843b412e5a8e";
    sha256 = "0q1kf3rkv9a30xdgxjr7qqibw90kk20f6bvr116d4x794kxyi72b";
    fetchSubmodules = false;
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = with ocamlPackages; [
    z3-everest fstar-master
    ocaml-visitors # TODO this will be available in next version of NixOS
    ocaml findlib batteries menhir stdint
    zarith camlp4 yojson pprint
    ulex ocaml-migrate-parsetree process ppx_deriving ppx_deriving_yojson ppx_tools_versioned
    ocamlbuild
    sedlex fix wasm
  ];

  makeFlags = [ "PREFIX=$(out)"
                "FSTAR_HOME=${fstar-master}"
                "KREMLIN_HOME=${src}"
              ];

  preBuild = ''
    # This is used by the 'install' target of kremlin
    mkdir -p $out/share/kremlin/misc; cp -r misc/* $out/share/kremlin/misc/

    mkdir -p $out/include; cp -r include/* $out/include/
  '';
  # into the 'out' (i'm not sure which way is better @volhovm)
  postInstall = ''
    # Hacl* (and possibly other programs) need this. It would bette be in share/ too
    # but everest infrastructure will assume exactly this path in many other
    # places (like Hacl* makefiles).
    #
    # It should be verified, so we put sources into the derivation after they were build.
    mkdir -p $out/kremlib; cp -r kremlib/* $out/kremlib/ # maybe put it under include too?

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
