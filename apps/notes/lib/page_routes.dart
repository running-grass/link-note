import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pages/topic_list.dart';

class AppRoutes extends StatelessWidget {
  const AppRoutes({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      home: TopicList(),
    );
  }
}
