import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todolist/main.dart';

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    if (kDebugMode) {
      print('onNotificationCreatedMethod');
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    if (kDebugMode) {
      print('onNotificationDisplayedMethod');
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (kDebugMode) {
      print('onDismissActionReceivedMethod');
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    SendPort? uiSendPort =
        IsolateNameServer.lookupPortByName('notification_actions');
    if (uiSendPort != null) {
      uiSendPort.send(receivedAction);
      return;
    }

    await _handleActionReceived(receivedAction);
  }

  @pragma("vm:entry-point")
  static Future<void> _handleActionReceived(
      ReceivedAction receivedAction) async {
    // Here you handle your notification actions

    // Navigate into pages, avoiding to open the notification details page twice
    // In case youre using some state management, such as GetX or get_route, use them to get the valid context instead
    // of using the Flutter's navigator key
    Get.to(const HomePage());
  }
}

addNotification({
  required int taskId,
  required String taskName,
  required DateTime dueDateTime,
  required DateTime remindDateTime,
  required bool isStrongReminder,
}) async {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: taskId,
      channelKey: 'reminder',
      title: taskName,
      body: 'Due today at ${DateFormat('hh:mm a').format(dueDateTime)}',
      category: isStrongReminder
          ? NotificationCategory.Alarm
          : NotificationCategory.Reminder,
    ),
    schedule: remindDateTime.millisecondsSinceEpoch <
            DateTime.now().millisecondsSinceEpoch
        ? null
        : NotificationCalendar.fromDate(
            date: remindDateTime,
            repeats: false,
            preciseAlarm: true,
            allowWhileIdle: true),
  );
}

deleteNotification({required int taskId}) {
  AwesomeNotifications().cancel(taskId);
}
