with import <nixpkgs> {};

mkShell {
  buildInputs = [
    # javascript
    nodejs
    purescript
    spago
    nodePackages.pnpm

    ipfs
  ];
}
