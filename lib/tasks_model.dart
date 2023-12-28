import 'dart:convert';

import 'package:get/get.dart';

List<Tasks> tasksFromMap(String str) =>
    List<Tasks>.from(json.decode(str).map((x) => Tasks.fromMap(x)));

String tasksToMap(List<Tasks> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Tasks {
  int taskId;
  RxString taskName;
  Rx<DateTime> dueDateTime;
  Rx<DateTime> remindDateTime;
  RxBool isCompleted;
  RxBool isStrongReminder;

  Tasks({
    required this.taskId,
    required this.taskName,
    required this.dueDateTime,
    required this.remindDateTime,
    required this.isCompleted,
    required this.isStrongReminder,
  });

  factory Tasks.fromMap(Map<String, dynamic> map) {
    String tempName = map['task_name'];

    bool tempComp = map['completed'] == 0 ? false : true;
    bool tempStrRemin = map['strong_reminder'] == 0 ? false : true;
    return Tasks(
      taskId: map['task_id'],
      taskName: tempName.obs,
      dueDateTime:
          DateTime.fromMillisecondsSinceEpoch(map['due_timestamp']).obs,
      remindDateTime:
          DateTime.fromMillisecondsSinceEpoch(map['remind_timestamp']).obs,
      isCompleted: tempComp.obs,
      isStrongReminder: tempStrRemin.obs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'task_name': taskName,
      'due_timestamp': dueDateTime.value.millisecondsSinceEpoch,
      'remind_timestamp': remindDateTime.value.millisecondsSinceEpoch,
      'completed': isCompleted.value,
      'strong_reminder': isStrongReminder,
    };
  }
}

enum RemindMeBefore { fiveMinutes, fifteenMinutes, oneHour }
