# learn-purs

## 用到的技术栈
1. purescript
2. spago
3. halogen
4. nix-shell（可选）
5. pnpm
6. ipfs
7. orbit-db
8. webpack
9. nodejs
10. direnv


## 搭建开发环境

### (可选) 安装nix
相关文档 https://nixos.org/manual/nix/stable/#sec-nix-shell
``` bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

安装手册  https://nixos.org/guides/install-nix.html

### （可选） 安装及配置direnv
官方文档 https://direnv.net/
前提是安装好了nix

``` bash
nix-env -iA nixpkgs.direnv
```

安装好了direnv之后， 在项目根目录执行 `direnv allow`，
并且在shell中配置好钩子，参考 https://direnv.net/docs/hook.html


### 使用spago编译purs文件
```bash
spago build
```

### 使用pnpm安装node_modeules依赖
```bash
pnpm install
```


### 启动调试模式
```bash
pnpm debug
```

