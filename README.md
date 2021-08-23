# link-note


## try me
最新版(v0.2.3)IPFS链接：  
HTTP版本： https://link-note.app/  

## 开发进度
https://sharing.clickup.com/b/h/4-7810727-2/4eeed303c8bfb07


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

### 使用pnpm安装node_modeules依赖
```bash
pnpm install
```

### 使用spago编译purs文件
```bash
spago build
```


### 启动调试模式
```bash
pnpm debug
```

## 开发文档

### 架构描述
根据purescript-realworld中的demo，把应用分为三层。
1. 全局状态层，文件为Store.purs。在渲染页面之前被初始化，包括全局配置、数据库连接等
2. 副作用能力层，接口目录为`src/Component`，具体实现为`src/Component/AppM.purs`，把应用需要使用的各种副作用从页面中剥离出来由这一层统一管理，也便于测试时的mock。包括数据库增删改查、记录日志、路由导航、随机数、当然时间等
3. 组件层，包括各种页面、组件、html片段、工具函数，这里只写纯函数。涉及到副作用的就会调用上一层的接口。需要读取应用配置的，就去读全局状态层(或许可以)

### 增加一个能力
1. 在src/Component目录中参考已有能力，增加一个文件。定义好需要的接口
2. 在AppM中去实现这个接口中的各个函数
3. 在Router.purs中为根组件声明这个能力Monad，在需要的页面组件中声明这个Monad.如果需要在工具函数中使用该能力也要声明。
