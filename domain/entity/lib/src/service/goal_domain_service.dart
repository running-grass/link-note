import 'package:model/model.dart';

import '../goal.dart';

class GoalDomainService {
  static late final GoalService _goalService = GoalService();

  static Stream<Iterable<GoalEntity>> getAllGoals$() {
    return _goalService.getAllGoal$().map((goals) => goals.map((goal) =>
        GoalEntity(
            id: goal.id,
            name: goal.name,
            accumType: goal.accumType,
            accumCount: goal.accumCount,
            accumSum: goal.accumSum,
            accumSumUnit: goal.accumSumUnit,
            accumTime: goal.accumTime,
            habitDurType: goal.habitDurType)));
  }
}
