with import <nixpkgs> {};

mkShell {
  buildInputs = [
    # javascript
    nodejs-18_x
    direnv
    nodePackages_latest.pnpm
  ];
}
