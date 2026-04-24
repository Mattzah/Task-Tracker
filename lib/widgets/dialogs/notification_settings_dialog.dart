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
  bool _eodEnabled = false;
  TimeOfDay _eodTime = const TimeOfDay(hour: 20, minute: 0);
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
      _eodEnabled = settings.eodEnabled;
      _eodTime = TimeOfDay(hour: settings.eodHour, minute: settings.eodMinute);
      _loading = false;
    });
  }

  Future<void> _pickTime(TimeOfDay initial, ValueChanged<TimeOfDay> onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
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
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    await _notificationService.requestPermissions();

    if (_enabled) {
      await _notificationService.scheduleDailyReminder(_time.hour, _time.minute);
    } else {
      await _notificationService.cancelDailyReminder();
    }

    if (_eodEnabled) {
      await _notificationService.scheduleEndOfDayReminder(_eodTime.hour, _eodTime.minute);
    } else {
      await _notificationService.cancelEndOfDayReminder();
    }

    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildTimeRow(String label, TimeOfDay time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF607B96),
                fontFamily: 'RobotoMono',
                fontSize: 11,
              ),
            ),
            Row(
              children: [
                Text(
                  time.format(context),
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
    );
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
                  const Row(
                    children: [
                      Icon(Icons.notifications_outlined, color: Color(0xFF00D4FF), size: 14),
                      SizedBox(width: 8),
                      Text(
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

                  // Morning reminder
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
                    _buildTimeRow(
                      'Reminder Time',
                      _time,
                      () => _pickTime(_time, (t) => setState(() => _time = t)),
                    ),
                  ],

                  const SizedBox(height: 12),
                  Container(height: 1, color: const Color(0xFF1E3A5F)),
                  const SizedBox(height: 12),

                  // End of day reminder
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'End of Day Reminder',
                        style: TextStyle(
                          color: Color(0xFFB0C4DE),
                          fontFamily: 'RobotoMono',
                          fontSize: 12,
                        ),
                      ),
                      Switch(
                        value: _eodEnabled,
                        onChanged: (val) => setState(() => _eodEnabled = val),
                        activeColor: const Color(0xFF00FF88),
                        inactiveThumbColor: const Color(0xFF607B96),
                        inactiveTrackColor: const Color(0xFF1E3A5F),
                      ),
                    ],
                  ),
                  if (_eodEnabled) ...[
                    const SizedBox(height: 8),
                    _buildTimeRow(
                      'Reminder Time',
                      _eodTime,
                      () => _pickTime(_eodTime, (t) => setState(() => _eodTime = t)),
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
