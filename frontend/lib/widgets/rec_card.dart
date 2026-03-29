import 'package:flutter/material.dart';
import '../models/models.dart';

class RecCard extends StatelessWidget {
  final Recommendation recommendation;

  const RecCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final typeColors = {
      'product': const Color(0xFF1A73E8),
      'content': const Color(0xFF34A853),
      'event': const Color(0xFF9C27B0),
    };
    final typeIcons = {
      'product': Icons.account_balance_wallet,
      'content': Icons.article,
      'event': Icons.event,
    };

    final color = typeColors[recommendation.type] ?? Colors.grey;

    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(typeIcons[recommendation.type] ?? Icons.star, color: color, size: 18),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  recommendation.type.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                ),
              ),
              const Spacer(),
              Text(
                '${(recommendation.confidenceScore * 100).round()}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            recommendation.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              recommendation.explanation,
              style: const TextStyle(fontSize: 12, color: Colors.white54, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
