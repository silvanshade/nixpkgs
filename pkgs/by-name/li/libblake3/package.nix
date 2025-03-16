{
  lib,
  stdenv,
  cmake,
  fetchFromGitHub,
  tbb,
  useTBB ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libblake3";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "BLAKE3-team";
    repo = "BLAKE3";
    rev = "a2516b78c2617d9ad289aeec91a02cb05d70cc17";
    # tag = finalAttrs.version;
    hash = "sha256-YJ3rRzpmF6oS8p377CEoRteARCD1lr/L7/fbN5poUXw=";
  };

  sourceRoot = finalAttrs.src.name + "/c";

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [] ++ lib.optionals useTBB [
    tbb
  ];

  cmakeFlags = [
    (lib.cmakeBool "BLAKE3_USE_TBB" useTBB)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ];

  meta = {
    description = "Official C implementation of BLAKE3";
    homepage = "https://github.com/BLAKE3-team/BLAKE3/tree/master/c";
    license = with lib.licenses; [
      asl20
      cc0
    ];
    maintainers = with lib.maintainers; [ fgaz silvanshade ];
    platforms = lib.platforms.all;
  };
})
