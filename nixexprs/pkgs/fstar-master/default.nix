{ stdenv, lib, pkgs, fetchFromGitHub, ocamlPackages, makeWrapper, z3-everest }:
# TODO: continue looking here for some more details: https://nixos.org/nixpkgs/manual/#build-phase

stdenv.mkDerivation rec {
  name = "fstar-master-${version}";
  version = "0.9.7.0-dev";

  src = fetchFromGitHub {
    owner = "FStarLang";
    repo = "FStar";
    rev = "66d92e8a21ae8f02f39970d7c1d080d6eddabe94";
    sha256 = "1jxmh6bjqm69jsrisqazqlhrhjpn0a6brc1h27df5x3asq8gxz4j";
    fetchSubmodules = false;
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = with ocamlPackages; [
    z3-everest ocaml findlib batteries menhir stdint
    zarith camlp4 yojson pprint
    ulex ocaml-migrate-parsetree process ppx_deriving ppx_deriving_yojson ocamlbuild
  ];

  makeFlags = [ "PREFIX=$(out)" ];

# TODO I don't know if ulib needs to be shebang patched
  preBuild = ''
    patchShebangs src/tools
    patchShebangs bin
    patchShebangs ulib
  '';
# actually, I just want it to run make all, which is run by `make`
#  buildFlags = "-C src/ocaml-output";

  preInstall = ''
    mkdir -p $out/lib/ocaml/${ocamlPackages.ocaml.version}/site-lib/fstarlib
  '';
# I want to do make all
  installFlags = "-C src/ocaml-output";
  # TODO This wrapper should find the z3 path using some command,
  # TODO it should not be hardcoded.
  postInstall = ''
    wrapProgram $out/bin/fstar.exe --prefix PATH ":" "${lib.getBin z3-everest}/bin"
  '';

  meta = with stdenv.lib; {
    description = "ML-like functional programming language aimed at program verification";
    homepage = https://www.fstar-lang.org;
    license = licenses.asl20;
    platforms = with platforms; darwin ++ linux;
    maintainers = [ "Benjamin Lipp <blipp@mailbox.org>" ];
  };
}
