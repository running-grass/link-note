import 'package:mobx/mobx.dart';
import 'package:model/model.dart';

part 'goal.g.dart';

class GoalEntity = _GoalEntity with _$GoalEntity;

class _GoalEntity with Store {
  static late final GoalService _goalService = GoalService();

  final int id;

  @observable
  String name;

  @observable
  HabitAccumType accumType;

  @observable
  late HabitDurType habitDurType;

  @observable
  int? accumCount;

  @observable
  int? accumSum;

  @observable
  String? accumSumUnit;

  @observable
  int? accumTime;

  _GoalEntity({
    required this.id,
    required this.name,
    required this.accumType,
    required this.habitDurType,
    required this.accumCount,
    required this.accumSum,
    required this.accumSumUnit,
    required this.accumTime,
  }) {
    // _loadData();
  }

  // @action
  // _loadData() {
  //   var goal = _goalService.getGoal(id);
  //   if (goal == null) {
  //     throw Error();
  //   }
  //   name = goal.name;
  //   accumType = goal.accumType;
  //   habitDurType = goal.habitDurType;
  //   accumCount = goal.accumCount;
  //   accumSum = goal.accumSum;
  //   accumSumUnit = goal.accumSumUnit;
  //   accumTime = goal.accumTime;
  // }
}
