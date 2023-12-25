import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../tasks_model.dart';

showAddTaskSheet() {
  Rx<DateTime> dueDate = DateTime.now().obs;
  Rx<TimeOfDay> dueTime = TimeOfDay.now().obs;
  RxBool strongReminder = false.obs;
  Rx<RemindMeBefore> remindMeBefore = RemindMeBefore.fiveMinutes.obs;

  TextEditingController textEditingController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  Rx<AutovalidateMode> autovalidateMode = AutovalidateMode.disabled.obs;

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
                      width: 68,
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
                  const SizedBox(
                    width: 68,
                  )
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
                        const Text(
                          'Add a task',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ).marginSymmetric(horizontal: 24, vertical: 24),
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
                        Flexible(
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
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xff007aff),
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xffc61f1f),
                                        ),
                                      ),
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xff737373),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ))),
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
                        InkWell(
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                                initialDate: dueDate.value,
                                context: Get.context!,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)));
                            if (selectedDate != null) {
                              dueDate.value = selectedDate;
                            }
                          },
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
                        ),
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
                        InkWell(
                          onTap: () async {
                            TimeOfDay? selectedTime = await showTimePicker(
                                context: Get.context!,
                                initialTime: dueTime.value);

                            if (selectedTime != null) {
                              dueTime.value = selectedTime;
                            }
                          },
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
                                  child: Obx(() => Text(
                                        dueTime.value.period.name.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )),
                                ),
                              ).marginOnly(left: 4)
                            ],
                          ),
                        ),
                      ],
                    ).marginSymmetric(
                      horizontal: 24,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
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
                    //         onChanged: (value) => strongReminder.toggle(),
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
                                DateTime remindDate;
                                DateTime tempDate = newDate;
                                if (remindMeBefore.value ==
                                    RemindMeBefore.fiveMinutes) {
                                  remindDate = tempDate
                                      .subtract(const Duration(minutes: 5));
                                } else if (remindMeBefore.value ==
                                    RemindMeBefore.fiveMinutes) {
                                  remindDate = tempDate
                                      .subtract(const Duration(minutes: 15));
                                } else {
                                  remindDate = tempDate
                                      .subtract(const Duration(hours: 1));
                                }

                                await database.transaction((txn) async {
                                  int id1 = await txn.rawInsert(
                                      'INSERT INTO tasks(task_name, due_timestamp, remind_timestamp,completed,strong_reminder) VALUES("$newTaskName", ${newDate.millisecondsSinceEpoch}, ${remindDate.millisecondsSinceEpoch},false,${strongReminder.value} )');
                                  Get.back(
                                      result: Tasks(
                                          taskId: id1,
                                          taskName: newTaskName.obs,
                                          dueDateTime: newDate.obs,
                                          remindDateTime: remindDate.obs,
                                          isCompleted: false.obs,
                                          isStrongReminder: strongReminder));
                                });
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
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
              ),
            ),
          ],
        ),
      ).marginOnly(top: 64),
      backgroundColor: Colors.transparent,
      isScrollControlled: true);
}

String formatTime(TimeOfDay time) {
  String hString = '';
  String mString = '';

  if (time.hourOfPeriod < 10) {
    hString = '0${time.hourOfPeriod}';
  } else {
    hString = '${time.hourOfPeriod}';
  }
  if (time.minute < 10) {
    mString = '0${time.minute}';
  } else {
    mString = '${time.minute}';
  }
  return '$hString : $mString';
}

class RemindMeDropdown extends StatefulWidget {
  final ValueChanged<RemindMeBefore> onChanged;

  const RemindMeDropdown({Key? key, required this.onChanged}) : super(key: key);

  @override
  _RemindMeDropdownState createState() => _RemindMeDropdownState();
}

class _RemindMeDropdownState extends State<RemindMeDropdown> {
  RemindMeBefore _selectedValue = RemindMeBefore.fiveMinutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButton<RemindMeBefore>(
        value: _selectedValue,
        onChanged: (value) {
          setState(() {
            _selectedValue = value!;
            widget.onChanged(value);
          });
        },
        underline: const SizedBox(), // Remove the default underline
        icon: const Icon(Icons.arrow_drop_down),
        items: RemindMeBefore.values.map((value) {
          return DropdownMenuItem<RemindMeBefore>(
            value: value,
            child: Text(
              _getDisplayText(value),
              style: const TextStyle(fontSize: 16.0),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getDisplayText(RemindMeBefore value) {
    switch (value) {
      case RemindMeBefore.fiveMinutes:
        return '5 Minutes Before';
      case RemindMeBefore.fifteenMinutes:
        return '15 Minutes Before';
      case RemindMeBefore.oneHour:
        return '1 Hour Before';
    }
  }
}
