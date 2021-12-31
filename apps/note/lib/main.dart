import 'package:flutter/material.dart';
import 'page_routes.dart';
import 'package:model/model.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initModel();

  initServices();
  runApp(const AppRoutes());
}

initServices() {
  Get.put(TopicService());
  Get.put(NoteService());
}
