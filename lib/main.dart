import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:todolist/Controllers.dart';
import 'package:todolist/components/bottolsheetcompoentnts.dart';
import 'package:todolist/components/preview_bottolsheet.dart';
import 'package:todolist/tasks_model.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

late Database database;
// late RxList<List<Tasks>> groupedTasksLists;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  TaskController taskController = Get.put(TaskController());
  runApp(const MyApp());
  var databasesPath = await getDatabasesPath();
  database = await openDatabase('$databasesPath/tasks.db', version: 1,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        'CREATE TABLE IF NOT EXISTS tasks ( task_id INTEGER PRIMARY KEY, task_name TEXT NOT NULL, due_timestamp TIMESTAMP,remind_timestamp TIMESTAMP, completed BOOLEAN DEFAULT false,strong_reminder BOOLEAN DEFAULT false )');
  });

  List<Map> list = await database.rawQuery('SELECT * FROM tasks');

  for (var element in list) {
    print(element);
    if (!taskController.allTasks.contains(element)) {
      taskController.allTasks.add(
        Tasks(
          taskId: element['task_id'],
          taskName: element['task_name'].toString().obs,
          dueDateTime:
              DateTime.fromMillisecondsSinceEpoch(element['due_timestamp']).obs,
          remindDateTime:
              DateTime.fromMillisecondsSinceEpoch(element['remind_timestamp'])
                  .obs,
          isCompleted:
              element['completed'] == false || element['completed'] == 0
                  ? false.obs
                  : true.obs,
          isStrongReminder: element['strong_reminder'] == false ||
                  element['strong_reminder'] == 0
              ? false.obs
              : true.obs,
        ),
      );
    }
  }

  FlutterNativeSplash.remove();
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
      home: HomePage(),
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
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TaskController taskController = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Tasks? resp = await showAddTaskSheet();
          if (resp != null) {
            taskController.allTasks.add(resp);
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

        Map<DateTime, List<Tasks>> groupedTasks =
            groupBy(taskController.allTasks, (Tasks obj) {
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

        return groupedTasks.isEmpty
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
            : ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: groupedTasks.length,
                itemBuilder: (context, index) {
                  final date = groupedTasks.keys.elementAt(index);
                  final groupedList = groupedTasks[date]!;

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
                              : DateFormat('MMM dd, yyyy').format(date),
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
                                isStrongReminder: obj.isStrongReminder,
                                remindDateTime: obj.remindDateTime,
                                taskName: obj.taskName,
                              ))
                          .toList(),
                    ),
                  );
                },
              ).paddingSymmetric(vertical: 24);
      })),
    );
  }
}

class TaskItem extends StatelessWidget {
  TaskItem({
    super.key,
    required this.taskId,
    required this.taskName,
    required this.dueDateTime,
    required this.remindDateTime,
    required this.isCompleted,
    required this.isStrongReminder,
  });
  final int taskId;
  final RxString taskName;
  final Rx<DateTime> dueDateTime;
  final Rx<DateTime> remindDateTime;
  final RxBool isCompleted;
  final RxBool isStrongReminder;
  TaskController taskController = Get.put(TaskController());
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
                            dueDateTime.value
                                        .difference(DateTime.now())
                                        .inDays ==
                                    0
                                ? 'Tomorrow'
                                : 'in ${dueDateTime.value.difference(DateTime.now()).inDays} ${dueDateTime.value.difference(DateTime.now()).inDays > 1 ? 'days' : 'day'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffa3a3a3),
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
