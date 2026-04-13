{ pkgs ? import <nixpkgs>{}}:

let
  perll = with pkgs; [
    perl
    perlnavigator
  ];

  perl_modules = with pkgs.perl5Packages; [
    Furl
    IOSocketSSL
  ];

in
pkgs.mkShell {
  nativeBuildInputs = perll ++ perl_modules;
}
