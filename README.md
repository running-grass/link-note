
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/leo1992/link-note?sort=date)

![GitHub commit activity](https://img.shields.io/github/commit-activity/m/link-note/link-note)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://dashboard.heroku.com/new-app?template=https://github.com/link-note/link-note)

# 愿景
致力于打造一个All In System的产品。已主题为圆心向外进行功能辐射。笔记卡片作为第一个圈。文件、文件夹、图片、音频、视频处在第二圈。pdf阅读、习惯打卡、任务管理、RSS订阅等处在第三圈。强调连接的重要性，把所有能连接的事物通过主题连接起来。打造第二大脑。

# 人群&场景&用途
1. 家庭分享空间
   1. 建一个宝宝相册，把和宝宝相关的照片和视频都放入其中。可以针对每个照片和视频添加笔记卡片，描述一下照片背后的故事，以及每次看到这个照片不同的感触
   2. 旅行计划及相册， 新建一个该旅行计划的主题，在该主题下列出计划安排，在每天的旅行日记主题中关联旅行计划主题。把上传的照片记录下当时的心情后关联旅行计划主题。 以后想重温该次旅行的话，从该旅行计划开始浏览，就可以找到所以和这次旅行相关的照片、心情、故事。
2. 公司知识库
   1. 产品和业务相关的资料文档，通过业务概念来关联到一起
   2. 技术相关知识库，通过技术名词关联到一起
   

# 技术栈
- nodejs@16 运行时环境
- pnpm 代替npm的包管理工具
- nestjs 后端的框架
- react 前端的UI框架
- typescript 前后端都使用强类型
- typeorm 后端使用的orm框架
- GraphQL 对于简单的数据CURD
- rxjs 配合mobx和其它异步的事件
- Apollo GraphQL的前后端框架
- sqlite 本地开发数据库
- mobx 前端的状态管理


## 相关文档
https://docs.nestjs.cn/8/firststeps
http://nodejs.cn/api-v16/
https://www.typescriptlang.org/docs/
https://typescript.bootcss.com/
https://typeorm.io/

## 关于nix
基于nix-shell中使用的node16是基于nix的unstable channel的

## 开发模式
```bash
pnpm i
pnpm run -r dev

# 如果需要重新生成generated下的文件
pnpm run -r codegen   # pnpm run -r watch:codegen
```

前端使用3000端口
后端使用4000端口


## 生产环境不是
1. 安装node14+和pnpm
2. 在项目根目录执行`make build`
3. 拷贝dist目录至服务器
4. 在服务器的dist中执行pnpm i -P 安装生产环境的依赖
   可以更改.env文件配置数据库连接及端口
5. 执行`pnpm run start:prod`