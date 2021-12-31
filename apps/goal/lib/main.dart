import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';

import 'add.dart';
import 'home.dart';
import 'edit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initModel();

  initServices();

  runApp(const MyApp());
}

initServices() {
  Get.put(TopicService());
  Get.put(NoteService());
  Get.put(GoalService());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '你好啊，flutter',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      // 当页面跳转时进行参数处理
      onGenerateRoute: (RouteSettings settings) {
        var routes = {
          '/': (context, {arguments}) => Home(),
          '/add': (context, {arguments}) => AddRoute(),
          '/edit': (context, {arguments}) =>
              EditRoute(habit: (arguments as Map)['habit']),
        };
        // 获取声明的路由页面函数
        var pageBuilder = routes[settings.name];
        if (pageBuilder != null) {
          if (settings.arguments != null) {
            // 创建路由页面并携带参数
            return MaterialPageRoute(
                builder: (context) =>
                    pageBuilder(context, arguments: settings.arguments));
          } else {
            return MaterialPageRoute(
                builder: (context) => pageBuilder(context));
          }
        }
        throw Error();
      },
    );
  }
}
