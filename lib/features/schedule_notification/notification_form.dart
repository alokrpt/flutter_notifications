import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notifications/features/schedule_notification/notification_service.dart';

class NotificationForm extends StatefulWidget {
  const NotificationForm({
    super.key,
    this.notificationRequest,
  });
  final PendingNotificationRequest? notificationRequest;
  @override
  State<NotificationForm> createState() => _NotificationFormState();
}

class _NotificationFormState extends State<NotificationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int? _notificationId;

  @override
  void initState() {
    if (widget.notificationRequest != null) {
      _titleController.text = widget.notificationRequest!.title ?? '';
      _descriptionController.text = widget.notificationRequest!.body ?? '';

      _notificationId = widget.notificationRequest!.id;
      final time = int.tryParse(widget.notificationRequest!.payload ?? '');

      if (time != null) {
        _selectedDate = DateTime.fromMillisecondsSinceEpoch(time);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '${widget.notificationRequest == null ? 'Create' : 'Edit'} Notification',
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(
            10,
          ),
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a message';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Scheduled at: ${_readableDate()}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final time = await _selectDate(context);
                    if (time != null) {
                      setState(() {
                        _selectedDate = time;
                      });
                    }
                  },
                  child: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    String title = _titleController.text;
                    String description = _descriptionController.text;
                    DateTime time = _selectedDate;
                    NotificationService.instance.scheduleNotification(
                      notificationId: _notificationId,
                      title: title,
                      description: description,
                      time: time,
                    );

                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _readableDate() {
    final str = _selectedDate.toLocal().toString();
    return str.replaceRange(16, str.length, '');
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      final time = await _selectTime(
        context,
        TimeOfDay.fromDateTime(_selectedDate),
      );
      return picked.copyWith(
        hour: time?.hour,
        minute: time?.minute,
      );
    }
    return null;
  }

  Future<TimeOfDay?> _selectTime(
      BuildContext context, TimeOfDay initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }
}
