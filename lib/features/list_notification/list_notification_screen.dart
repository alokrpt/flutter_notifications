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
    return RefreshIndicator(
      onRefresh: () => fetchScheduledNotifications(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upcoming Notifications'),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            await openNotificationForm(context, null);
          },
        ),
        body: notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No upcoming notifications \nCreate a new notification by clicking + icon',
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () => fetchScheduledNotifications(),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) => Card(
                  elevation: 2,
                  margin: const EdgeInsets.all(16).copyWith(bottom: 0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Id: ${notifications[index].id}'),
                        Text('Title: ${notifications[index].title}'),
                        Text('Message: ${notifications[index].body}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                NotificationService
                                    .instance.localNotificationPlugin
                                    .cancel(notifications[index].id);
                                fetchScheduledNotifications();
                              },
                              child: const Text('Delete'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await openNotificationForm(
                                    context, notifications[index]);
                              },
                              child: const Text('Edit'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> openNotificationForm(
    BuildContext context,
    PendingNotificationRequest? notificationRequest,
  ) async {
    final isUpdated = await showDialog(
      context: context,
      builder: (context) => NotificationForm(
        notificationRequest: notificationRequest,
      ),
    );
    if (isUpdated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification Saved Successfully!',
          ),
        ),
      );
      fetchScheduledNotifications();
    }
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
