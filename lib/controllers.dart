// ignore: file_names
import 'package:get/get.dart';
import 'package:todolist/tasks_model.dart';

class TaskController extends GetxController {
  RxList<Tasks> allTasks = <Tasks>[].obs;
  RxList<Tasks> comingTasks = <Tasks>[].obs;
  RxList<Tasks> overDueTasks = <Tasks>[].obs;
}
