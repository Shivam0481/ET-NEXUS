import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String label;
  final String value;
  final double confidence;
  final IconData icon;
  final Color color;

  const ProfileCard({
    super.key,
    required this.label,
    required this.value,
    required this.confidence,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
            ),
            // Confidence indicator
            Column(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: confidence,
                    strokeWidth: 3,
                    backgroundColor: Colors.white10,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(confidence * 100).round()}%',
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
