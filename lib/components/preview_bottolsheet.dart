import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todolist/main.dart';
import 'package:todolist/notification_controller.dart';

import '../tasks_model.dart';
import 'bottolsheetcompoentnts.dart';

showPreviewTaskSheet({required Tasks tasks, required taskController}) {
  Rx<DateTime> dueDate = tasks.dueDateTime;
  Rx<TimeOfDay> dueTime = TimeOfDay(
          hour: tasks.dueDateTime.value.hour,
          minute: tasks.dueDateTime.value.minute)
      .obs;
  RxBool strongReminder = tasks.isStrongReminder;
  Rx<RemindMeBefore> remindMeBefore = RemindMeBefore.fiveMinutes.obs;

  TextEditingController textEditingController =
      TextEditingController(text: tasks.taskName.value);
  var formKey = GlobalKey<FormState>();
  Rx<AutovalidateMode> autovalidateMode = AutovalidateMode.disabled.obs;
  RxBool isEditing = false.obs;
  return Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xfff7f8fa),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            Container(
              alignment: AlignmentDirectional.center,
              decoration: const BoxDecoration(
                  color: Color(0xfff4f4f4),
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xffadaeaf),
                    ),
                  ),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: const SizedBox(
                      width: 72,
                      child: Row(children: [
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xff007aff),
                          size: 20,
                        ),
                        Text(
                          'Close',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff007aff)),
                        ),
                      ]),
                    ),
                  ),
                  const Text(
                    'Task',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff000000)),
                  ),
                  InkWell(
                    onTap: () => isEditing.toggle(),
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: SizedBox(
                      width: 72,
                      child: Row(children: [
                        Obx(() => isEditing.value
                            ? const SizedBox()
                            : const Icon(
                                Icons.edit,
                                color: Color(0xff007aff),
                                size: 18,
                              )),
                        const SizedBox(
                          width: 4,
                        ),
                        Obx(() => Text(
                              isEditing.value ? 'Cancel' : 'Edit',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff007aff)),
                            )),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // padding: EdgeInsets.all(24),
                  // shrinkWrap: true,
                  children: [
                    Row(
                      children: [
                        Obx(() => Text(
                              isEditing.value ? 'Update task' : 'Task',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            )).marginSymmetric(horizontal: 24, vertical: 24),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Obx(() => isEditing.value
                            ? Flexible(
                                child: Obx(() => Form(
                                      autovalidateMode: autovalidateMode.value,
                                      key: formKey,
                                      child: TextFormField(
                                        controller: textEditingController,
                                        validator: (value) =>
                                            value.toString().isEmpty
                                                ? 'Please add task name'
                                                : null,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff000000)),
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. Exercise, Read Book',
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xff737373),
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xffc61f1f),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xff007aff),
                                            ),
                                          ),
                                          hintStyle: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xff737373),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )))
                            : Flexible(
                                child: Text(
                                  tasks.taskName.value,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff000000)),
                                ),
                              )),
                      ],
                    ).marginSymmetric(
                      horizontal: 24,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 64,
                          child: Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Obx(() => InkWell(
                              onTap: isEditing.value
                                  ? () async {
                                      DateTime? selectedDate =
                                          await showDatePicker(
                                              initialDate: dueDate.value,
                                              context: Get.context!,
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime.now().add(
                                                  const Duration(days: 365)));
                                      if (selectedDate != null) {
                                        dueDate.value = selectedDate;
                                      }
                                    }
                                  : null,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xffe7e8eb),
                                ),
                                child: Obx(() => Text(
                                      DateFormat('MMM dd, yyyy')
                                          .format(dueDate.value),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )),
                              ),
                            )),
                      ],
                    ).marginSymmetric(
                      horizontal: 24,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 64,
                          child: Text(
                            'Hour',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Obx(() => InkWell(
                              onTap: isEditing.value
                                  ? () async {
                                      TimeOfDay? selectedTime =
                                          await showTimePicker(
                                              context: Get.context!,
                                              initialTime: dueTime.value);

                                      if (selectedTime != null) {
                                        dueTime.value = selectedTime;
                                      }
                                    }
                                  : null,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xffe7e8eb),
                                    ),
                                    child: Obx(() => Text(
                                          formatTime(dueTime.value),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2, vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xffe7e8eb),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        boxShadow: const [
                                          BoxShadow(
                                              blurRadius: 4,
                                              blurStyle: BlurStyle.outer,
                                              color: Color(0xffe7e8eb))
                                        ],
                                        borderRadius: BorderRadius.circular(8),
                                        color: const Color(0xffffffff),
                                      ),
                                      child: Obx(
                                        () => Text(
                                          dueTime.value.period.name
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ).marginOnly(left: 4)
                                ],
                              ),
                            )),
                      ],
                    ).marginSymmetric(
                      horizontal: 24,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Obx(
                      () => AnimatedCrossFade(
                        firstChild: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 64,
                                  child: Text(
                                    'Remind',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                RemindMeDropdown(
                                  onChanged: (value) {
                                    remindMeBefore.value = value;
                                  },
                                )
                              ],
                            ).marginSymmetric(
                              horizontal: 24,
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     const SizedBox(
                            //       width: 150,
                            //       child: Text(
                            //         'Strong Reminder',
                            //         style: TextStyle(
                            //           fontSize: 18,
                            //           fontWeight: FontWeight.w600,
                            //         ),
                            //       ),
                            //     ),
                            //     Obx(
                            //       () => Switch(
                            //         activeColor: const Color(0xff007aff),
                            //         activeTrackColor:
                            //             const Color(0xff007aff).withOpacity(.3),
                            //         inactiveThumbColor: const Color(0xff737373),
                            //         inactiveTrackColor: const Color(0xfff7f8fa),
                            //         value: strongReminder.value,
                            //         onChanged: (value) =>
                            //             strongReminder.toggle(),
                            //       ),
                            //     ),
                            //   ],
                            // ).marginSymmetric(
                            //   horizontal: 24,
                            // ),
                            const SizedBox(
                              height: 24,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      autovalidateMode.value =
                                          AutovalidateMode.onUserInteraction;
                                      if (formKey.currentState!.validate()) {
                                        final newTaskName =
                                            textEditingController.text.trim();
                                        DateTime newDate = DateTime(
                                          dueDate.value.year,
                                          dueDate.value.month,
                                          dueDate.value.day,
                                          dueTime.value.hour,
                                          dueTime.value.minute,
                                          0,
                                          0,
                                          0,
                                        );
                                        DateTime tempDate = newDate;
                                        if (remindMeBefore.value ==
                                            RemindMeBefore.fiveMinutes) {
                                          tempDate.subtract(
                                              const Duration(minutes: 5));
                                        } else if (remindMeBefore.value ==
                                            RemindMeBefore.fiveMinutes) {
                                          tempDate.subtract(
                                              const Duration(minutes: 15));
                                        } else {
                                          tempDate.subtract(
                                              const Duration(hours: 1));
                                        }
                                        DateTime remindDate = tempDate;

                                        int id = await database.rawUpdate(
                                            'UPDATE tasks SET task_name = ?, due_timestamp = ?,remind_timestamp = ?,completed = ?,strong_reminder = ? WHERE task_id = ${tasks.taskId}',
                                            [
                                              '$newTaskName',
                                              '${newDate.millisecondsSinceEpoch}',
                                              '${remindDate.millisecondsSinceEpoch}',
                                              '0',
                                              '${strongReminder.value}'
                                            ]);
                                        taskController.allTasks.removeWhere(
                                            (element) =>
                                                element.taskId == tasks.taskId);
                                        taskController.allTasks.add(Tasks(
                                            taskId: id,
                                            taskName: newTaskName.obs,
                                            dueDateTime: newDate.obs,
                                            remindDateTime: remindDate.obs,
                                            isCompleted: false.obs,
                                            isStrongReminder: strongReminder));
                                        deleteNotification(taskId: id);
                                        addNotification(
                                            taskId: id,
                                            taskName: newTaskName,
                                            dueDateTime: newDate,
                                            remindDateTime: remindDate,
                                            isStrongReminder:
                                                strongReminder.value);

                                        Get.back();
                                      }
                                    },
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Container(
                                      alignment: AlignmentDirectional.center,
                                      decoration: BoxDecoration(
                                          color: const Color(0xff171717),
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: const Text(
                                        'Done',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ).marginSymmetric(horizontal: 24)
                          ],
                        ),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(
                              height: 24,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      if (tasks.isCompleted.value) {
                                        await database.rawUpdate(
                                            'UPDATE tasks SET completed = ? WHERE task_id = ${tasks.taskId}',
                                            [0]);
                                        tasks.isCompleted.value = true;
                                        Get.back();

                                        taskController.allTasks
                                            .firstWhere((element) =>
                                                element.taskId == tasks.taskId)
                                            .isCompleted
                                            .value = false;
                                        addNotification(
                                            taskId: tasks.taskId,
                                            taskName: tasks.taskName.value,
                                            dueDateTime:
                                                tasks.dueDateTime.value,
                                            remindDateTime:
                                                tasks.remindDateTime.value,
                                            isStrongReminder:
                                                tasks.isStrongReminder.value);
                                      } else {
                                        await database.rawUpdate(
                                            'UPDATE tasks SET completed = ? WHERE task_id = ${tasks.taskId}',
                                            [1]);
                                        tasks.isCompleted.value = true;
                                        Get.back();

                                        taskController.allTasks
                                            .firstWhere((element) =>
                                                element.taskId == tasks.taskId)
                                            .isCompleted
                                            .value = true;
                                        deleteNotification(
                                            taskId: tasks.taskId);
                                      }
                                    },
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Obx(() => Container(
                                          alignment:
                                              AlignmentDirectional.center,
                                          decoration: tasks.isCompleted.value
                                              ? BoxDecoration(
                                                  color:
                                                      const Color(0xff171717),
                                                  borderRadius:
                                                      BorderRadius.circular(16))
                                              : BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                          colors: [
                                                        Color(0xffb634c5),
                                                        Color(0xff25c8ab),
                                                      ]),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Obx(() => Icon(
                                                    tasks.isCompleted.value
                                                        ? Icons.add_rounded
                                                        : Icons
                                                            .done_all_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  )),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Obx(() => Text(
                                                    tasks.isCompleted.value
                                                        ? 'Re Open'
                                                        : 'Complete',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  )),
                                            ],
                                          ),
                                        )),
                                  ),
                                )
                              ],
                            ).marginSymmetric(horizontal: 24),
                            const SizedBox(
                              height: 24,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      await database.rawDelete(
                                          'DELETE FROM tasks WHERE task_id = ?',
                                          [tasks.taskId]);
                                      tasks.isCompleted.value = true;

                                      taskController.allTasks.removeWhere(
                                          (element) =>
                                              element.taskId == tasks.taskId);
                                      deleteNotification(taskId: tasks.taskId);

                                      Get.back();
                                    },
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Container(
                                      alignment: AlignmentDirectional.center,
                                      decoration: BoxDecoration(
                                          color: const Color(0xffc61f1f),
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.remove_circle_outline_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            'Remove Task',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ).marginSymmetric(horizontal: 24),
                          ],
                        ),
                        crossFadeState: isEditing.value
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ).marginOnly(top: 64),
      backgroundColor: Colors.transparent,
      isScrollControlled: true);
}
