import 'package:get/get.dart';

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
    return Tasks(
      taskId: map['task_id'],
      taskName: map['task_name'],
      dueDateTime:
          DateTime.fromMillisecondsSinceEpoch(map['due_timestamp']).obs,
      remindDateTime:
          DateTime.fromMillisecondsSinceEpoch(map['remind_timestamp']).obs,
      isCompleted: map['completed'],
      isStrongReminder: map['strong_reminder'],
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
