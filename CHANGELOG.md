# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### 新特性
- 双中括号打开最近使用过的主题，单击可以快速增加链接

## 优化
- 修复单击链接会触发编辑状态的问题

## [0.5.0] - 2021-09-04
### 新特性
- 增加对内部链接的渲染和跳转支持
- 如果主题不存在，自动创建主题
## [0.4.0] - 2021-08-27
### 新特性
- 设置页面新增三个功能
    1. 修改配置IPFS实例配置
    2. 导出下载数据库
    3. 删除数据库
- 打开IPFS的支持，且可以在设置页面切换配置。默认不使用IPFS
- 使用上下箭头移动光标
- 使用Shift+上下箭头在父节点下移动当前笔记

### 优化
- 主题列表——主题名称不会重复，把新建主题改为了进入主题。如果主题不存在，则自动新建主题
- 修复调整笔记层级之后不会自动获得焦点的问题
- 每天会提醒一次`当前软件处于不稳定的状态`
- 优化了一下主题详情页的样式

## [0.3.0] - 2021-08-22
### 新特性
- 新页面 主题列表/主题详情/设置 页面
- 支持主题概念，笔记要依赖于某个主题存在
- 主题详情页面的笔记支持树形层级展示
- Tab/S-Tab可以调整笔记层级
### 其它
- 每次版本发布会支持
- IPFS不再是必要选项，暂时关闭IPFS支持
## [0.2.2] - 2021-08-07
### bugfix
- 节点失焦后刷新不及时
## [0.2.1] - 2021-08-07
### bugfix
- 输入和回车混乱
## [0.2.0] - 2021-08-07

### 新功能
- 可以粘贴文件到笔记中，会保存到配置好的IPFS中
- 自动对图片类型文件进行解析

### 优化
- 可以在笔记点击编辑，ESC退出编辑，回车删除
- 优化打包后的体积，从10M降为3M
- 简单的适配移动端


## [0.1.0] - 2021-07-24

- 基于Purescript的开发框架
- 基于Halogen的Web框架
- 引入Rxdb作为浏览器端的数据库
- 简单的文本保存、删除、编辑

## [0.0.1] - 2021-07-16

- Init Project


[Unreleased]: https://github.com/link-note/link-note/compare/0.5.0...HEAD
[0.5.0]: https://github.com/link-note/link-note/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/link-note/link-note/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/link-note/link-note/compare/0.2.2...0.3.0
[0.2.2]: https://github.com/running-grass/learn-purs/compare/0.2.1...0.2.2
[0.2.1]: https://github.com/running-grass/learn-purs/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/running-grass/learn-purs/compare/0.1.0...0.2.0
