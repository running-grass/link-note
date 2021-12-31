// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ListStore on _ListStore, Store {
  final _$allListAtom = Atom(name: '_ListStore.allList');

  @override
  ObservableList<GoalEntity> get allList {
    _$allListAtom.reportRead();
    return super.allList;
  }

  @override
  set allList(ObservableList<GoalEntity> value) {
    _$allListAtom.reportWrite(value, super.allList, () {
      super.allList = value;
    });
  }

  @override
  String toString() {
    return '''
allList: ${allList}
    ''';
  }
}
