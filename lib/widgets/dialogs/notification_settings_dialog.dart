import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationSettingsDialog extends StatefulWidget {
  const NotificationSettingsDialog({super.key});

  @override
  State<NotificationSettingsDialog> createState() => _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState extends State<NotificationSettingsDialog> {
  final NotificationService _notificationService = NotificationService();
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _notificationService.loadSettings();
    setState(() {
      _enabled = settings.enabled;
      _time = TimeOfDay(hour: settings.hour, minute: settings.minute);
      _loading = false;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: Color(0xFF0D1526),
            hourMinuteColor: Color(0xFF111D35),
            hourMinuteTextColor: Color(0xFF00D4FF),
            dayPeriodColor: Color(0xFF111D35),
            dayPeriodTextColor: Color(0xFF00D4FF),
            dialBackgroundColor: Color(0xFF111D35),
            dialHandColor: Color(0xFF00D4FF),
            dialTextColor: Color(0xFFB0C4DE),
            entryModeIconColor: Color(0xFF607B96),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_enabled) {
      await _notificationService.requestPermissions();
      await _notificationService.scheduleDailyReminder(_time.hour, _time.minute);
    } else {
      await _notificationService.cancelDailyReminder();
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1526),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF1E3A5F)),
        borderRadius: BorderRadius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _loading
            ? const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF))),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_outlined, color: Color(0xFF00D4FF), size: 14),
                      const SizedBox(width: 8),
                      const Text(
                        'NOTIFICATIONS',
                        style: TextStyle(
                          color: Color(0xFF00D4FF),
                          fontFamily: 'RobotoMono',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 1, color: const Color(0xFF1E3A5F)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daily Reminder',
                        style: TextStyle(
                          color: Color(0xFFB0C4DE),
                          fontFamily: 'RobotoMono',
                          fontSize: 12,
                        ),
                      ),
                      Switch(
                        value: _enabled,
                        onChanged: (val) => setState(() => _enabled = val),
                        activeColor: const Color(0xFF00FF88),
                        inactiveThumbColor: const Color(0xFF607B96),
                        inactiveTrackColor: const Color(0xFF1E3A5F),
                      ),
                    ],
                  ),
                  if (_enabled) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111D35),
                          border: Border.all(color: const Color(0xFF1E3A5F)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Reminder Time',
                              style: TextStyle(
                                color: Color(0xFF607B96),
                                fontFamily: 'RobotoMono',
                                fontSize: 11,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _time.format(context),
                                  style: const TextStyle(
                                    color: Color(0xFF00D4FF),
                                    fontFamily: 'RobotoMono',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.edit, color: Color(0xFF607B96), size: 12),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('CANCEL'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _save,
                        child: const Text(
                          'SAVE',
                          style: TextStyle(color: Color(0xFF00FF88)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
