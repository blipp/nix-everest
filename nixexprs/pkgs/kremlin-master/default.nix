{ stdenv, lib, pkgs, fetchFromGitHub, ocamlPackages, makeWrapper, z3-everest, fstar-master, ocaml-visitors }:

stdenv.mkDerivation rec {
  name = "kremlin-master-${version}";
  version = "0.9.6.0";

  src = fetchFromGitHub {
    owner = "FStarLang";
    repo = "kremlin";
    rev = "8e2499453d4abf04996147b735157eb4c62088b5";
    sha256 = "0c60sgj6zwhpc2djm9wh2dz1h6n0kpx6cjf13si4qjx9w5knmbdf";
    fetchSubmodules = false;
  };
#  src = fetchFromGitHub {
#    owner = "blipp";
#    repo = "kremlin";
#    rev = "b385c8add11edcefbd79e8c6f630d3d10f2b66d7";
#    sha256 = "1syip0w4d6ny4dhhyyqkld2f4qfri4xviibv6qqplahd3qy98v6s";
#    fetchSubmodules = false;
#  };

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
                ##"OCAMLPATH=" TODO Do I need to set this?
                "FSTAR_HOME=${lib.getBin fstar-master}"
                "KREMLIN_HOME=${src}"
              ];

  # TODO Kremlin needs ulib, maybe this sits at the required path but without 'u',
  # TODO because './lib/fstar/FStar.UInt128.fst' exists in the store…

# TODO I don't know if ulib needs to be shebang patched
  #preBuild = ''
    #patchShebangs src/tools
    #patchShebangs bin
    #patchShebangs ulib
  #'';
# actually, I just want it to run make all, which is run by `make`
#  buildFlags = "-C src/ocaml-output";

#  preInstall = ''
#    mkdir -p $out/lib/ocaml/${ocamlPackages.ocaml.version}/site-lib/fstarlib
#  '';
# I want to do make all
#  installFlags = "-C src/ocaml-output";
  postInstall = ''
    wrapProgram $out/bin/krml --set FSTAR_HOME "${lib.getBin fstar-master}" --set KREMLIN_HOME "${src}"
  '';

  meta = with stdenv.lib; {
    description = "KreMLin is a tool for extracting low-level F* programs to readable C code";
    homepage = https://fstarlang.github.io/lowstar/html/;
    license = licenses.asl20;
    platforms = with platforms; darwin ++ linux;
    maintainers = [ "Benjamin Lipp <blipp@mailbox.org>" ];
  };
}
