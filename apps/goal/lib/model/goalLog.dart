import 'package:model/model.dart';

// part 'goalLog.g.dart';

class GoalLog {
  int goalLogId = 0;

  // 习惯名称
  int goalId;

  // log时间
  DateTime logTime = DateTime.now();

  // 数据模型版本
  int version = 1;

  // 记录一下当下的类型
  HabitAccumType accumType;

  int? recordSum;

  int? recordTime;

  GoalLog({required this.goalId, required this.accumType});
}
