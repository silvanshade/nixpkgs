{ lib
, stdenv
, fetchFromGitLab
, cargo
, desktop-file-utils
, meson
, ninja
, pkg-config
, rustPlatform
, rustc
, wrapGAppsHook4
, cairo
, gdk-pixbuf
, glib
, gtk4
, libadwaita
, pango
, gettext
, darwin
}:

stdenv.mkDerivation rec {
  pname = "diebahn";
  version = "2.4.0";

  src = fetchFromGitLab {
    owner = "schmiddi-on-mobile";
    repo = "railway";
    rev = version;
    hash = "sha256-2iLxErEP0OG+BcG7fvJBzNjh95EkNoC3NC7rKxPLhYk=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    name = "${pname}-${src}";
    inherit src;
    hash = "sha256-TyafdFWCaZgLEW2yVfm9+9kXRKoiyCAbRndcb7XCVdI=";
  };

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk4
    libadwaita
    pango
  ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
    CoreFoundation
    Foundation
    Security
  ]);

  # Darwin needs to link against gettext from nixpkgs instead of the one vendored by gettext-sys
  # because the vendored copy does not build with newer versions of clang.
  env = lib.optionalAttrs stdenv.isDarwin {
    GETTEXT_BIN_DIR = "${lib.getBin gettext}/bin";
    GETTEXT_INCLUDE_DIR = "${lib.getDev gettext}/include";
    GETTEXT_LIB_DIR = "${lib.getLib gettext}/lib";
  };

  meta = {
    changelog = "https://gitlab.com/schmiddi-on-mobile/railway/-/blob/${src.rev}/CHANGELOG.md";
    description = "Travel with all your train information in one place";
    homepage = "https://gitlab.com/schmiddi-on-mobile/railway";
    license = lib.licenses.gpl3Plus;
    mainProgram = "diebahn";
    maintainers = with lib.maintainers; [ dotlambda lilacious ];
  };
}
