import 'package:flutter/material.dart';
import 'package:notes/page_routes.dart';
import 'package:models/models.dart';
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
