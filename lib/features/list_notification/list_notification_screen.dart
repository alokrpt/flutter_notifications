import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notifications/features/schedule_notification/notification_service.dart';

import '../schedule_notification/notification_form.dart';

class ListNotificationScreen extends StatefulWidget {
  const ListNotificationScreen({super.key});

  @override
  State<ListNotificationScreen> createState() => _ListNotificationScreenState();
}

class _ListNotificationScreenState extends State<ListNotificationScreen> {
  List<PendingNotificationRequest> notifications = [];
  @override
  void initState() {
    fetchScheduledNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Notifications'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final isUpdated = await showModalBottomSheet(
            context: context,
            builder: (context) => NotificationForm(),
          );
          if (isUpdated) {}
        },
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) => Card(
          child: Column(
            children: [
              Text('Id: ${notifications[index].id}'),
              Text('Title: ${notifications[index].title}'),
              Text('Message: ${notifications[index].body}'),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Delete'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Edit'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchScheduledNotifications() async {
    List<PendingNotificationRequest> notifications = await NotificationService
        .instance.localNotificationPlugin
        .pendingNotificationRequests();
    setState(() {
      this.notifications = notifications;
    });
  }
}
