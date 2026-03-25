import 'package:flutter/material.dart';
import '../../services/points_service.dart';

class StatsDialog extends StatefulWidget {
  final PointsService pointsService;

  const StatsDialog({super.key, required this.pointsService});

  @override
  State<StatsDialog> createState() => _StatsDialogState();
}

class _StatsDialogState extends State<StatsDialog> {
  AppStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await widget.pointsService.getStats();
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1526),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFFFFD700), width: 1),
        borderRadius: BorderRadius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 8),
                const Text(
                  'STATS',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontFamily: 'RobotoMono',
                    fontSize: 13,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(height: 1, color: const Color(0x44FFD700)),
            const SizedBox(height: 16),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFD700),
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              _buildStats(_stats!),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(
                    color: Color(0xFF607B96),
                    fontFamily: 'RobotoMono',
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(AppStats stats) {
    return Column(
      children: [
        _buildStatRow(
          icon: Icons.local_fire_department,
          iconColor: const Color(0xFFFF6B35),
          label: 'CURRENT STREAK',
          value: '${stats.currentStreak} day${stats.currentStreak == 1 ? '' : 's'}',
          badge: (stats.isCurrentStreakLongest && stats.currentStreak > 0)
              ? 'BEST'
              : null,
        ),
        const SizedBox(height: 10),
        _buildStatRow(
          icon: Icons.emoji_events,
          iconColor: const Color(0xFFFFD700),
          label: 'LONGEST STREAK',
          value:
              '${stats.longestStreak} day${stats.longestStreak == 1 ? '' : 's'}',
        ),
        const SizedBox(height: 10),
        _buildStatRow(
          icon: Icons.star,
          iconColor: const Color(0xFF00D4FF),
          label: 'BIGGEST DAY',
          value: stats.biggestDayPoints > 0
              ? '${stats.biggestDayPoints} pts'
              : 'N/A',
          subtitle: stats.biggestDayDate != null
              ? _formatDate(stats.biggestDayDate!)
              : null,
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? badge,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF080C18),
        border: Border.all(color: const Color(0xFF1E3A5F), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF607B96),
                    fontFamily: 'RobotoMono',
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF607B96),
                      fontFamily: 'RobotoMono',
                      fontSize: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFB0C4DE),
              fontFamily: 'RobotoMono',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.15),
                border:
                    Border.all(color: const Color(0xFFFFD700), width: 0.5),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontFamily: 'RobotoMono',
                  fontSize: 8,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
