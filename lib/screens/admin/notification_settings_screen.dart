import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../widgets/ad_banner_widget.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  TimeOfDay _dailyTime = const TimeOfDay(hour: 18, minute: 0);
  int _weeklyDay = 1; // Monday
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final time = await _notificationService.getDailyNotificationTime();
    setState(() {
      _dailyTime = TimeOfDay(hour: time['hour']!, minute: time['minute']!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Send Instant Notification'),
                  _buildInstantNotificationCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Daily Reading Reminder'),
                  _buildDailyReminderCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Weekly Reminder'),
                  _buildWeeklyReminderCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Quick Actions'),
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildInstantNotificationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Send a notification to all users immediately',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Notification Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Notification Message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.message),
              ),
              maxLines: 3,
              maxLength: 150,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _sendInstantNotification,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(_isLoading ? 'Sending...' : 'Send Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyReminderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Remind users to read stories every day',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Notification Time'),
              subtitle: Text(_dailyTime.format(context)),
              trailing: const Icon(Icons.edit),
              onTap: _selectDailyTime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _scheduleDailyNotification,
              icon: const Icon(Icons.schedule),
              label: const Text('Update Daily Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyReminderCard() {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Send weekly featured story notifications',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _weeklyDay,
              decoration: InputDecoration(
                labelText: 'Day of Week',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              items: List.generate(7, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(weekdays[index]),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _weeklyDay = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _scheduleWeeklyNotification,
              icon: const Icon(Icons.calendar_month),
              label: const Text('Update Weekly Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_active, color: Colors.blue),
            title: const Text('Test Notification'),
            subtitle: const Text('Send a test notification to this device'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _sendTestNotification,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.new_releases, color: Colors.orange),
            title: const Text('Notify New Story'),
            subtitle: const Text('Send notification about latest story'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _notifyNewStory,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cancel_outlined, color: Colors.red),
            title: const Text('Cancel All Notifications'),
            subtitle: const Text('Cancel all scheduled notifications'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _cancelAllNotifications,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDailyTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dailyTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dailyTime) {
      setState(() {
        _dailyTime = picked;
      });
    }
  }

  Future<void> _sendInstantNotification() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both title and message'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.sendInstantNotification(
        title: _titleController.text,
        body: _messageController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Notification sent successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        _titleController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scheduleDailyNotification() async {
    try {
      await _notificationService.scheduleDailyNotification(
        hour: _dailyTime.hour,
        minute: _dailyTime.minute,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Daily reminder scheduled for ${_dailyTime.format(context)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _scheduleWeeklyNotification() async {
    try {
      await _notificationService.scheduleWeeklyNotification(
        weekday: _weeklyDay,
        hour: 10,
        minute: 0,
      );

      if (mounted) {
        final weekdays = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Weekly reminder scheduled for ${weekdays[_weeklyDay - 1]} at 10:00 AM',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    await _notificationService.sendInstantNotification(
      title: 'Test Notification 📱',
      body: 'This is a test notification from Love Stories app!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _notifyNewStory() async {
    await _notificationService.sendInstantNotification(
      title: 'New Story Available! 💕',
      body: 'A beautiful new love story has been added. Read it now!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New story notification sent!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _cancelAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel All Notifications?'),
        content: const Text(
          'This will cancel all scheduled notifications. Users will not receive any reminders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _notificationService.cancelAllNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cancelled'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
