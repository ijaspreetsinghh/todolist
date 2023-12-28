import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todolist/components/preview_bottolsheet.dart';
import 'package:todolist/controllers.dart';
import 'package:todolist/main.dart';
import 'package:todolist/notification_controller.dart';
import 'package:todolist/tasks_model.dart';

class TaskItem extends StatelessWidget {
  TaskItem(
      {super.key,
      required this.taskId,
      required this.taskName,
      required this.dueDateTime,
      required this.remindDateTime,
      required this.isCompleted,
      required this.isStrongReminder,
      required this.taskController});
  final int taskId;
  final RxString taskName;
  final Rx<DateTime> dueDateTime;
  final Rx<DateTime> remindDateTime;
  final RxBool isCompleted;
  final RxBool isStrongReminder;
  final TaskController taskController;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showPreviewTaskSheet(
            taskController: taskController,
            tasks: Tasks(
                taskId: taskId,
                taskName: taskName,
                dueDateTime: dueDateTime,
                remindDateTime: remindDateTime,
                isCompleted: isCompleted,
                isStrongReminder: isStrongReminder));
      },
      child: SizedBox(
        height: 64,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Obx(() => Checkbox(
                  value: isCompleted.value,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(
                      color: Color(0xffe8e8e8),
                    ),
                  ),
                  activeColor: const Color(0xff000000), //Color(0xff007aff)
                  onChanged: (v) async {
                    taskController.allTasks
                        .where((p0) => p0.taskId == taskId)
                        .first
                        .isCompleted
                        .toggle();

                    await database.rawUpdate(
                        'UPDATE tasks SET completed = ? WHERE task_id = $taskId',
                        [v! ? 1 : 0]);

                    v
                        ? deleteNotification(taskId: taskId)
                        : addNotification(
                            taskId: taskId,
                            taskName: taskName.value,
                            dueDateTime: dueDateTime.value,
                            remindDateTime: remindDateTime.value,
                            isStrongReminder: isStrongReminder.value);
                  },
                  visualDensity: VisualDensity.comfortable,
                )),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => Text(
                        taskName.value,
                        // Limit the number of lines
                        overflow: TextOverflow
                            .ellipsis, // Handle overflow with ellipsis
                        style: TextStyle(
                          decoration: isCompleted.value
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: const Color(0xffd0d0d2),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isCompleted.value
                              ? const Color(0xffd0d0d2)
                              : const Color(0xff737373),
                        ),
                      )),
                  Obx(() => Row(
                        children: [
                          Text(
                            DateFormat('hh:mm a').format(dueDateTime.value),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              decorationColor: const Color(0xffd0d0d2),
                              decoration: isCompleted.value
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: isCompleted.value
                                  ? const Color(0xffd0d0d2)
                                  : const Color(0xffa3a3a3),
                            ),
                          ),
                          isStrongReminder.value
                              ? const Icon(
                                  Icons.alarm_on_rounded,
                                  color: Color(0xff007aff),
                                  size: 14,
                                ).marginOnly(left: 4, right: 4)
                              : const Icon(
                                  Icons.notifications_active_outlined,
                                  color: Color(0xff007aff),
                                  size: 14,
                                ).marginOnly(left: 4, right: 4),
                          Text(
                            isCompleted.value
                                ? 'Completed'
                                : dueDateTime.value
                                            .difference(DateTime.now())
                                            .inDays <
                                        0
                                    ? 'Overdue'
                                    : dueDateTime.value
                                                .difference(DateTime.now())
                                                .inDays ==
                                            0
                                        ? 'Today'
                                        : dueDateTime.value
                                                    .difference(DateTime.now())
                                                    .inDays ==
                                                1
                                            ? 'Tomorrow'
                                            : 'in ${dueDateTime.value.difference(DateTime.now()).inDays} ${dueDateTime.value.difference(DateTime.now()).inDays > 1 ? 'days' : 'day'}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isCompleted.value
                                  ? const Color(0xffa3a3a3)
                                  : dueDateTime.value
                                              .difference(DateTime.now())
                                              .inDays <
                                          0
                                      ? const Color(0xffc61f1f)
                                      : const Color(0xffa3a3a3),
                            ),
                          )
                        ],
                      ))
                ],
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 16),
      ),
    ).marginOnly(bottom: 8);
  }
}
