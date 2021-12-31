import 'package:entity/entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
import 'package:goal/mobx/list_store.dart';
// import 'package:model/model.dart';

import 'model/goalLog.dart';

var currMonth = DateTime(now.year, now.month);

var currWeek = today.subtract(Duration(days: today.weekday - 1));
var currYear = DateTime(now.year);
var now = DateTime.now();
var today = DateTime(now.year, now.month, now.day);

Future<int> getAccumNum(String unit) async {
  String tempSum = "";
  // GoalService goalService = GoalService();

  await Get.defaultDialog(
    title: '请填写',
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(11),
              FilteringTextInputFormatter.digitsOnly
            ],
            keyboardType: TextInputType.number,
            onChanged: (value) => tempSum = value,
          ),
        ),
        Text(unit),
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          if (tempSum.isEmpty) {
            tempSum = "1";
          }
          Get.back();
        },
        child: const Text('确定'),
      ),
    ],
  );
  return int.parse(tempSum);
}

onItemTap(GoalEntity habit) async {
  GoalLog habitLog;
  int sum;
  // 记录一条log
  switch (habit.accumType) {
    case HabitAccumType.unknown:
    case HabitAccumType.count:
      sum = 1;
      habitLog = GoalLog(goalId: habit.id, accumType: habit.accumType);
      break;
    case HabitAccumType.sum:
      sum = await getAccumNum(habit.accumSumUnit!);
      habitLog = GoalLog(goalId: habit.id, accumType: habit.accumType)
        ..recordSum = sum;
      break;
    case HabitAccumType.time:
      sum = await getAccumNum("分钟");
      habitLog = GoalLog(goalId: habit.id, accumType: habit.accumType)
        ..recordTime = sum;
      break;
  }
  // await goalLogsRef.add(habitLog);
  Get.snackbar("操作成功", "增加$sum", snackPosition: SnackPosition.BOTTOM);
}

enum HabitFinishStatus {
  pending,
  finish,
}

ItemStatus _itemStatusFunc(GoalEntity habit, Iterable<GoalLog> habitLogs) {
  Iterable<GoalLog> list;
  switch (habit.habitDurType) {
    case HabitDurType.unknown:
    case HabitDurType.day:
      list = habitLogs.where((e) => e.logTime.isAfter(today));
      break;
    case HabitDurType.week:
      list = habitLogs.where((e) => e.logTime.isAfter(currWeek));
      break;
    case HabitDurType.month:
      list = habitLogs.where((e) => e.logTime.isAfter(currMonth));
      break;
    case HabitDurType.year:
      list = habitLogs.where((e) => e.logTime.isAfter(currYear));
      break;
  }

  switch (habit.accumType) {
    case HabitAccumType.unknown:
    case HabitAccumType.count:
      int len = list.length;

      var status = len >= habit.accumCount!
          ? HabitFinishStatus.finish
          : HabitFinishStatus.pending;
      return ItemStatus("($len/${habit.accumCount})", status);

    case HabitAccumType.sum:
      var list1 = list.map((e) => e.recordSum!);
      int sum = list1.isEmpty ? 0 : list1.reduce((acc, e) => acc + e);

      var status = sum >= habit.accumSum!
          ? HabitFinishStatus.finish
          : HabitFinishStatus.pending;
      return ItemStatus(
          "($sum/${habit.accumSum}${habit.accumSumUnit})", status);

    case HabitAccumType.time:
      var list1 = list.map((e) => e.recordTime!);
      int sum = list1.isEmpty ? 0 : list1.reduce((acc, e) => acc + e);

      var status = sum >= habit.accumTime!
          ? HabitFinishStatus.finish
          : HabitFinishStatus.pending;

      return ItemStatus("($sum/${habit.accumTime}分钟)", status);
  }
}

class HabitItemCard extends StatelessWidget {
  final Function() onTap;

  final Iterable<GoalLog> habitLogs;

  final GoalEntity habit;

  const HabitItemCard(
      {Key? key,
      required this.habit,
      required this.onTap,
      this.habitLogs = const []})
      : super(key: key);

  ItemStatus get _itemStatus {
    return _itemStatusFunc(habit, habitLogs);
  }

  bool get _isFinish => _itemStatus.status == HabitFinishStatus.finish;

  bool get _isPending => _itemStatus.status == HabitFinishStatus.pending;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _isPending ? onTap : null,
        onLongPress: () {
          Get.toNamed('/edit', arguments: {'habit': habit});
        },
        child: Card(
            color: _isFinish ? Colors.green : Colors.amber,
            child: SizedBox(
                width: 150,
                height: 200,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isFinish ? Icons.task_alt : Icons.schedule),
                      Container(
                          padding: const EdgeInsets.only(top: 20, bottom: 5),
                          child: Text(habit.name)),
                      Text(_itemStatus.progressText),
                    ]))));
  }
}

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);
  var listStore = ListStore();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日习惯'),
        actions: [
          IconButton(
              onPressed: () {
                Get.toNamed('/profile');
              },
              icon: const Icon(Icons.person))
        ],
      ),
      floatingActionButton: IconButton(
          iconSize: 100,
          icon: Ink(
            width: 80,
            height: 80,
            decoration: const ShapeDecoration(
              shape: CircleBorder(),
            ),
            child: const Icon(
              Icons.add_circle_sharp,
              size: 80,
            ),
          ),
          splashColor: Theme.of(context).primaryColor,
          onPressed: () {
            Get.toNamed('/add');
          }),
      body: Observer(
        builder: (_) => GridView.count(
          crossAxisCount: 3,
          children: listStore.allList.map((GoalEntity goal) {
            return Center(
                child:
                    HabitItemCard(habit: goal, onTap: () => onItemTap(goal)));
          }).toList(),
        ),
      ),
    );
  }
}

class ItemStatus {
  final String progressText;
  final HabitFinishStatus status;

  ItemStatus(this.progressText, this.status);
}
