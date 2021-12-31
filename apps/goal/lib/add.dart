import 'package:entity/entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
// import 'package:model/model.dart';
// import 'package:model/model.dart';

import 'habit_form.dart';

class AddRoute extends StatelessWidget {
  AddRoute({Key? key}) : super(key: key);
  GoalService _goalService = GoalService();

  final Goal habit = Goal(
    name: '',
    accumType: HabitAccumType.count,
    habitDurType: HabitDurType.day,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加习惯'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: HabitForm(
            habit: habit,
            handleSubmit: (Goal habit) async {
              _goalService.addCountGoal(
                  name: habit.name, count: habit.accumCount!);

              Get.back();

              Get.snackbar("操作成功", "新增目标", snackPosition: SnackPosition.BOTTOM);
            }),
      ),
    );
  }
}
