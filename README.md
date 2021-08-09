# learn-purs

项目名称未定

## try me
最新版(v0.2.2)IPFS链接：
IPFS协议： ipfs://bafybeidst3lnobpo4k2oeciamfefrzztu6xwvquwtioe6gqzsg4u3tht64/
DWeb网关： https://bafybeidst3lnobpo4k2oeciamfefrzztu6xwvquwtioe6gqzsg4u3tht64.ipfs.dweb.link/

## 用到的技术栈

1. nix-shell 搭建本地开发环境，提供各种开发需要的命令行程序，独立于系统已安装的程序。 不会有任何冲突
10. direnv 当进入项目目录的时候，自动执行nix-shell来进入开发环境

1. purescript 主语言
2. spago purescript的包管理工具，类似npm
3. halogen purescript语言下的ui框架，类似于react

2. javascript 辅助语言、引入各种已有的js库
5. pnpm npm/yarn的代替品，用来大幅度降低磁盘使用情况，让不同的项目可以复用node_modules，增加安全性

9. nodejs webpack的依赖
8. webpack 最终把js和purs集成打包到一起的工具

6. ipfs 分布式文件传输协议，类似于bt+git
7. rxdb 基于pouchdb的离线优先数据库

## 搭建开发环境

最好基于Brave浏览器开发
并且本地需要启动IPFS节点，并且配置API的跨域为*

### (可选) 安装nix
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

