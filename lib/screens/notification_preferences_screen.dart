import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../widgets/ad_banner_widget.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = true;
  TimeOfDay _dailyTime = const TimeOfDay(hour: 18, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final enabled = await _notificationService.getNotificationsEnabled();
      final time = await _notificationService.getDailyNotificationTime();

      setState(() {
        _notificationsEnabled = enabled;
        _dailyTime = TimeOfDay(hour: time['hour']!, minute: time['minute']!);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 24),
                      _buildNotificationToggle(),
                      const SizedBox(height: 16),
                      if (_notificationsEnabled) ...[
                        _buildDailyReminderCard(),
                        const SizedBox(height: 16),
                        _buildTestNotificationCard(),
                      ],
                      const SizedBox(height: 24),
                      _buildInfoCard(),
                    ],
                  ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 0,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stay Updated',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get notified about new stories and reading reminders',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        value: _notificationsEnabled,
        onChanged: _toggleNotifications,
        title: const Text(
          'Enable Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _notificationsEnabled
              ? 'You\'ll receive reminders and updates'
              : 'No notifications will be sent',
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _notificationsEnabled
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _notificationsEnabled ? Icons.notifications : Icons.notifications_off,
            color: _notificationsEnabled ? Colors.green : Colors.grey,
          ),
        ),
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDailyReminderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.alarm, color: Colors.blue),
            ),
            title: const Text(
              'Daily Reading Reminder',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Remind me at ${_dailyTime.format(context)}'),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: const Text('Change Time'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestNotificationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.settings_suggest, color: Colors.orange),
        ),
        title: const Text(
          'Test Notification',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Send a test notification to see how it looks'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _sendTestNotification,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'About Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Notifications work even when the app is closed\n'
              '• You\'ll be reminded to read new stories daily\n'
              '• Get instant alerts when new stories are published\n'
              '• You can disable notifications anytime',
              style: TextStyle(
                color: Colors.blue.shade900,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });

    await _notificationService.setNotificationsEnabled(value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                value ? Icons.check_circle : Icons.info,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value
                      ? 'Notifications enabled'
                      : 'Notifications disabled',
                ),
              ),
            ],
          ),
          backgroundColor: value ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _selectTime() async {
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

      await _notificationService.scheduleDailyNotification(
        hour: picked.hour,
        minute: picked.minute,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Daily reminder set for ${picked.format(context)}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    await _notificationService.sendInstantNotification(
      title: 'Test Notification 📖',
      body: 'This is how notifications will look on your device!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.send, color: Colors.white),
              SizedBox(width: 8),
              Text('Test notification sent!'),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'Check',
            textColor: Colors.white,
            onPressed: () {
              // Pull down notification shade
            },
          ),
        ),
      );
    }
  }
}
