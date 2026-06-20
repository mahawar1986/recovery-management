import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/customer_provider.dart';
import '../../providers/target_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/section_title.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  String fmt(double n) => n >= 100000 ? '₹${(n/100000).toStringAsFixed(1)}L' : n >= 1000 ? '₹${(n/1000).toStringAsFixed(0)}K' : '₹${n.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CustomerProvider>();
    final tp = context.watch<TargetProvider>();
    final villages = cp.villageBreakdown;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        const SectionTitle('VILLAGE-WISE RECOVERY'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: villages.entries.toList()
                ..sort((a,b) => (b.value['outstanding'] as double).compareTo(a.value['outstanding'] as double)),
            ).children.map((e) {
              if (e is! MapEntry<String, Map<String, dynamic>>) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('📍 ${e.key}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(fmt(e.value['outstanding'] as double), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.danger)),
                  ]),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: cp.totalOutstanding > 0 ? (e.value['outstanding'] as double) / cp.totalOutstanding : 0,
                    color: AppColors.primary, backgroundColor: AppColors.border, minHeight: 5,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  Text('${e.value['count']} accounts', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ]),
              );
            }).toList(),
          ),
        ),

        const SectionTitle('STATUS BREAKDOWN'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(
                child: SizedBox(
                  height: 140,
                  child: PieChart(PieChartData(
                    sections: [
                      PieChartSectionData(value: cp.customers.where((c)=>c.status=='NPA').length.toDouble(), color: AppColors.danger, title: 'NPA', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      PieChartSectionData(value: cp.customers.where((c)=>c.status=='PTP').length.toDouble(), color: AppColors.warning, title: 'PTP', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      PieChartSectionData(value: cp.customers.where((c)=>c.status=='Active').length.toDouble(), color: AppColors.success, title: 'Active', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  )),
                ),
              ),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Legend('NPA', AppColors.danger, '${cp.npaCount}'),
                _Legend('PTP', AppColors.warning, '${cp.customers.where((c)=>c.status=="PTP").length}'),
                _Legend('Active', AppColors.success, '${cp.customers.where((c)=>c.status=="Active").length}'),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  final String label; final Color color; final String value;
  const _Legend(this.label, this.color, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text('$label: $value', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}
