import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model/model.dart';

class HabitForm extends StatefulWidget {
  final Function(Goal habit) handleSubmit;

  final Goal habit;
  HabitForm({Key? key, required this.handleSubmit, required this.habit})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FormState();
  }
}

Map<HabitAccumType, String> habitAccumType = {
  HabitAccumType.count: "计数",
  HabitAccumType.sum: "计量",
  HabitAccumType.time: "计时",
};

Map<HabitDurType, String> habitDurTypeMap = {
  HabitDurType.day: "每天",
  HabitDurType.week: "每周",
  HabitDurType.month: "每月",
  HabitDurType.year: "每年",
};

String? validateStr(String? value) {
  if (value == null || value.isEmpty) {
    return '不能为空';
  }
  return null;
}

class _FormState extends State<HabitForm> {
  final _formKey = GlobalKey<FormState>();

  String name = "";
  _FormState();

  void submit() {
    var _state = _formKey.currentState;
    if (_state!.validate()) {
      _state.save();
      widget.handleSubmit(widget.habit);
    }
  }

  List<Widget> buildAccumType() {
    List<Widget> list = [];
    switch (widget.habit.accumType) {
      case HabitAccumType.unknown:

      case HabitAccumType.count:
        list = [
          const Text("次数"),
          TextFormField(
            key: const Key("count"),
            initialValue: (widget.habit.accumCount ?? 1).toString(),
            validator: validateStr,
            inputFormatters: [
              LengthLimitingTextInputFormatter(11),
              FilteringTextInputFormatter.digitsOnly
            ],
            keyboardType: TextInputType.number,
            onSaved: (value) {
              widget.habit.accumCount = int.parse(value!);
            },
          )
        ];
        break;
      case HabitAccumType.sum:
        list = [
          const Text("计量"),
          TextFormField(
            key: const Key("accumSum"),
            initialValue: (widget.habit.accumSum ?? 10).toString(),
            validator: validateStr,
            inputFormatters: [
              LengthLimitingTextInputFormatter(11),
              FilteringTextInputFormatter.digitsOnly
            ],
            keyboardType: TextInputType.number,
            onSaved: (value) {
              widget.habit.accumSum = int.parse(value!);
            },
          ),
          const Text("计数单位"),
          TextFormField(
            key: const Key("accumSumUnit"),
            initialValue: widget.habit.accumSumUnit,
            validator: validateStr,
            onSaved: (value) {
              widget.habit.accumSumUnit = value!;
            },
          ),
        ];
        break;
      case HabitAccumType.time:
        list = [
          const Text("分钟"),
          TextFormField(
            key: const Key("accumTime"),
            initialValue: (widget.habit.accumTime ?? 20).toString(),
            validator: validateStr,
            inputFormatters: [
              LengthLimitingTextInputFormatter(11),
              FilteringTextInputFormatter.digitsOnly
            ],
            keyboardType: TextInputType.number,
            onSaved: (value) {
              widget.habit.accumTime = int.parse(value!);
            },
          )
        ];
        break;
    }
    list.insertAll(0, [
      const Text("统计类型"),
      DropdownButton<HabitAccumType>(
        value: widget.habit.accumType,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        style: const TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),
        onChanged: (HabitAccumType? newValue) {
          widget.habit.accumType = newValue!;
          setState(() {});
        },
        items: habitAccumType.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
      )
    ]);

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("习惯"),
          TextFormField(
            initialValue: name,
            onSaved: (value) {
              name = value!;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入习惯名称';
              }
              return null;
            },
          ),
          const Text("目标周期"),
          DropdownButton<HabitDurType>(
            value: widget.habit.habitDurType,
            onChanged: (HabitDurType? newValue) {
              widget.habit.habitDurType = newValue!;
              setState(() {});
            },
            items: habitDurTypeMap.entries
                .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
          ),
          ...buildAccumType(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: submit,
              child: const Text('保存'),
            ),
          ),
        ],
      ),
    );
  }
}
