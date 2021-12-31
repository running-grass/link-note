import 'package:objectbox/objectbox.dart';

import 'enums.dart';

@Entity()
class Goal {
  int id = 0;

  // 习惯名称
  String name;

  HabitAccumType accumType;

  int? accumCount;

  int? accumSum;

  String? accumSumUnit;

  /// 单位为分钟
  int? accumTime;

  /// 周期
  HabitDurType habitDurType;

  // 习惯的状态
  HabitStatus status;

  // 创建时间
  late DateTime created;

  late DateTime updated;
  Goal({
    required this.name,
    this.accumType = HabitAccumType.count,
    this.habitDurType = HabitDurType.day,
    this.status = HabitStatus.enable,
    this.accumCount,
    this.accumSum,
    this.accumSumUnit,
    this.accumTime,
    DateTime? created,
    DateTime? updated,
  }) {
    this.created = created ?? DateTime.now();
    this.updated = updated ?? DateTime.now();
  }
}
