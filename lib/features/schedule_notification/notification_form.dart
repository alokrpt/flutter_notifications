import 'package:flutter/material.dart';
import 'package:flutter_notifications/features/schedule_notification/notification_service.dart';

class NotificationForm extends StatelessWidget {
  NotificationForm({super.key});
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Selected Date: ${_selectedDate.toLocal()}',
                ),
              ),
              TextButton(
                onPressed: () => _selectDate(context),
                child: const Text('Select Date'),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                String title = _titleController.text;
                String description = _descriptionController.text;
                DateTime time = _selectedDate;
                NotificationService.instance.scheduleNotification(
                  title,
                  description,
                  time,
                );

                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      return picked;
    }
    return null;
  }
}
