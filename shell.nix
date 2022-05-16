with import <nixpkgs> {};

mkShell {
  buildInputs = [
    # javascript
    nodejs-16_x
    nodePackages.pnpm
  ];
}
