import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';

import 'habit_form.dart';

class EditRoute extends StatelessWidget {
  final Goal habit;

  const EditRoute({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑习惯'),
        actions: [
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await Get.defaultDialog(
                    title: "提示",
                    onConfirm: () {
                      // habit.delete();
                      throw Error();

                      Get.back();
                    },
                    textConfirm: "是的",
                    content: const Text("您确定删除该目标么？"));
                Get.back();
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: HabitForm(
          handleSubmit: (Goal habit) async {
            // habit.save()
            throw Error();

            Get.back();

            Get.snackbar("操作成功", "编辑目标", snackPosition: SnackPosition.BOTTOM);
          },
          habit: habit,
        ),
      ),
    );
  }
}
