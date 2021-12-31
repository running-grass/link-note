import '../../objectbox.g.dart';

import '../enums.dart';
import '../store.dart';
import '../goal.dart';

class GoalService {
  // 单例处理
  GoalService._internal();
  factory GoalService() => _instance;
  static late final GoalService _instance = GoalService._internal();

  late final Box<Goal> _goalBox = store.box<Goal>();

  Goal addCountGoal({
    required String name,
    required int count,
    HabitDurType? habitDurType,
  }) {
    var goal = Goal(
        name: name,
        accumCount: count,
        habitDurType: habitDurType ?? HabitDurType.day);
    _goalBox.put(goal);
    return goal;
  }

  Stream<List<Goal>> getAllGoal$() {
    var queryBuilder = _goalBox.query(Goal_.id.notNull());
    queryBuilder..order(Goal_.updated, flags: Order.descending);

    return queryBuilder.watch(triggerImmediately: true).map((Query<Goal> qg) {
      return qg.find();
    });
  }
}
