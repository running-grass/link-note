import 'package:mobx/mobx.dart';
import 'package:entity/entity.dart';

part 'list_store.g.dart';

class ListStore = _ListStore with _$ListStore;

abstract class _ListStore with Store {
  @observable
  ObservableList<GoalEntity> allList = ObservableList.of([]);

  _ListStore() {
    GoalDomainService.getAllGoals$().listen((ges) {
      allList = ObservableList.of(ges);
    });
  }
}
