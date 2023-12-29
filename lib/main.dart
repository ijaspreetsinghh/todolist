import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:todolist/components/bottolsheetcompoentnts.dart';
import 'package:todolist/components/task_item.dart';
import 'package:todolist/controllers.dart';
import 'package:todolist/notification_controller.dart';
import 'package:todolist/tasks_model.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

late Database database;
// late RxList<List<Tasks>> groupedTasksLists;

Future<void> initializeDatabase() async {
  var databasesPath = await getDatabasesPath();
  database = await openDatabase('$databasesPath/tasks.db', version: 1,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        'CREATE TABLE IF NOT EXISTS tasks ( task_id INTEGER PRIMARY KEY, task_name TEXT NOT NULL, due_timestamp TIMESTAMP,remind_timestamp TIMESTAMP, completed BOOLEAN DEFAULT false,strong_reminder BOOLEAN DEFAULT false )');
  });
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await initializeDatabase();
  TaskController taskController = Get.put(TaskController());
  taskController.allTasks = <Tasks>[].obs;
  // taskController.overDueTasks.clear();
  // taskController.comingTasks.clear();
  List<Map> list = await database.rawQuery('SELECT * FROM tasks');
  taskController.allTasks = tasksFromMap(jsonEncode(list)).obs;

  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'reminder',
      channelName: 'reminder',
      channelGroupKey: 'reminder_group',
      channelDescription: 'Reminder of tasks',
      importance: NotificationImportance.High,
      enableVibration: true,
      criticalAlerts: true,
    )
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupKey: 'reminder_group', channelGroupName: 'Reminder Group')
  ]);
  FlutterNativeSplash.remove();
  runApp(const MyApp());
  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();

  if (!isAllowedToSendNotification) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialBinding: HomeBinding(),
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<TaskController>(TaskController());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TaskController taskController = Get.put(TaskController());
  @override
  void dispose() {
    database.close();
    super.dispose();
  }

  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // String localTimeZone =
          //     await AwesomeNotifications().getLocalTimeZoneIdentifier();

          Tasks? resp = await showAddTaskSheet();
          if (resp != null) {
            taskController.allTasks.add(resp);

            addNotification(
                taskId: resp.taskId,
                taskName: resp.taskName.value,
                dueDateTime: resp.dueDateTime.value,
                remindDateTime: resp.remindDateTime.value,
                isStrongReminder: resp.isStrongReminder.value);
          }
        },
        backgroundColor: const Color(0xff171717),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Color(0xfffafafa),
          size: 32,
        ),
      ),
      body: SafeArea(child: Obx(() {
        taskController.allTasks
            .sort((a, b) => a.dueDateTime.value.compareTo(b.dueDateTime.value));

        // Remove Overdue tasks from the original list based on the yesterday

        taskController.overDueTasks = RxList.from(taskController.allTasks
            .where((el) => el.dueDateTime.value.isBefore(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  0,
                  0,
                  0,
                  0,
                ))));
        // Create a new list for only new tasks, coming ahead

        taskController.comingTasks = RxList.from(taskController.allTasks
            .where((el) => el.dueDateTime.value.isAfter(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  0,
                  0,
                  0,
                  0,
                ))));

        Map<DateTime, List<Tasks>> comingGroupedTasks =
            groupBy(taskController.comingTasks, (Tasks obj) {
          return DateTime(
            obj.dueDateTime.value.year,
            obj.dueDateTime.value.month,
            obj.dueDateTime.value.day,
            0,
            0,
            0,
            0,
            0,
          );
        });

        Map<DateTime, List<Tasks>> overDueGroupedTasks =
            groupBy(taskController.overDueTasks, (Tasks obj) {
          return DateTime(
            obj.dueDateTime.value.year,
            obj.dueDateTime.value.month,
            obj.dueDateTime.value.day,
            0,
            0,
            0,
            0,
            0,
          );
        });
        taskController.update();
        return Obx(() => taskController.allTasks.isEmpty
            ? Container(
                margin: const EdgeInsets.symmetric(vertical: 24),
                height: Get.height * .85,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Tasks',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ).marginOnly(bottom: 12, left: 24, right: 24),
                      ],
                    ),
                    SizedBox(
                      height: Get.height * .4,
                    ),
                    const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Tap + to create task',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                color: Color(0xffa3a3a3)),
                          )
                        ]),
                  ],
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    taskController.overDueTasks.isEmpty
                        ? const SizedBox()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: overDueGroupedTasks.length,
                            itemBuilder: (context, index) {
                              final date =
                                  overDueGroupedTasks.keys.elementAt(index);
                              final groupedList = overDueGroupedTasks[date]!;

                              return ListTile(
                                title: const Text(
                                  'Overdue',
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: Color(0xffc61f1f),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ).marginOnly(bottom: 12, left: 24, right: 24),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: groupedList
                                      .map((obj) => TaskItem(
                                            taskId: obj.taskId,
                                            dueDateTime: obj.dueDateTime,
                                            isCompleted: obj.isCompleted,
                                            taskController: taskController,
                                            isStrongReminder:
                                                obj.isStrongReminder,
                                            remindDateTime: obj.remindDateTime,
                                            taskName: obj.taskName,
                                          ))
                                      .toList(),
                                ),
                              );
                            },
                          ).paddingOnly(
                            top: 24,
                          ),
                    taskController.comingTasks.isEmpty
                        ? const SizedBox()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: comingGroupedTasks.length,
                            itemBuilder: (context, index) {
                              final date =
                                  comingGroupedTasks.keys.elementAt(index);
                              final groupedList = comingGroupedTasks[date]!;

                              return ListTile(
                                title: Text(
                                  date ==
                                          DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                            0,
                                            0,
                                            0,
                                            0,
                                          )
                                      ? 'Today'
                                      : date ==
                                              DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                DateTime.now().day + 1,
                                                0,
                                                0,
                                                0,
                                                0,
                                              )
                                          ? 'Tomorrow'
                                          : DateFormat('MMM dd, yyyy')
                                              .format(date),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ).marginOnly(bottom: 12, left: 24, right: 24),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: groupedList
                                      .map((obj) => TaskItem(
                                            taskId: obj.taskId,
                                            dueDateTime: obj.dueDateTime,
                                            isCompleted: obj.isCompleted,
                                            taskController: taskController,
                                            isStrongReminder:
                                                obj.isStrongReminder,
                                            remindDateTime: obj.remindDateTime,
                                            taskName: obj.taskName,
                                          ))
                                      .toList(),
                                ),
                              );
                            },
                          ).paddingOnly(bottom: 24)
                  ],
                ),
              ));
      })),
    );
  }
}
