import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, bg;
  final String? sub;
  const StatCard({super.key, required this.label, required this.value, required this.icon, required this.color, required this.bg, this.sub});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          if (sub != null) Text(sub!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ])),
        Container(width: 38, height: 38, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20)),
      ]),
    ),
  );
}
