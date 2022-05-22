with import <nixpkgs> {};

mkShell {
  buildInputs = [
    # javascript
    nodejs-18_x
    nodePackages_latest.pnpm

    direnv


    # 部署docker使用
    gh
    heroku
  ];
}
