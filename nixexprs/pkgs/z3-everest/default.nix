{ stdenv, fetchFromGitHub, python, fixDarwinDylibNames }:

stdenv.mkDerivation rec {
  name = "z3-everest-${version}";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner  = "Z3Prover";
    repo   = "z3";
    rev    = "1f29cebd4df633a4fea50a29b80aa756ecd0e8e7";
    sha256 = "0fn50fjcwps25q07z4mp90qmgmq8863jmzc76qb5cband4xg4r3j";
  };

  buildInputs = [ python fixDarwinDylibNames ];
  propagatedBuildInputs = [ python.pkgs.setuptools ];
  enableParallelBuilding = true;

  configurePhase = ''
    ${python.interpreter} scripts/mk_make.py --prefix=$out --python --pypkgdir=$out/${python.sitePackages} --githash 1f29cebd4df6
    cd build
  '';

  postInstall = ''
    mkdir -p $dev $lib $python/lib

    mv $out/lib/python*  $python/lib/
    mv $out/lib          $lib/lib
    mv $out/include      $dev/include

    ln -sf $lib/lib/libz3${stdenv.hostPlatform.extensions.sharedLibrary} $python/${python.sitePackages}/z3/lib/libz3${stdenv.hostPlatform.extensions.sharedLibrary}
  '';

  outputs = [ "out" "lib" "dev" "python" ];

  meta = {
    description = "A high-performance theorem prover and SMT solver";
    homepage    = "https://github.com/Z3Prover/z3";
    license     = stdenv.lib.licenses.mit;
    platforms   = stdenv.lib.platforms.unix;
    maintainers = [ "Benjamin Lipp <blipp@mailbox.org>" ];
  };
}
