import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/target_provider.dart';
import '../../utils/app_theme.dart';
import 'dashboard_screen.dart';
import 'customers_screen.dart';
import 'analytics_screen.dart';
import 'upload_screen.dart';
import 'reports_screen.dart';

class ManagerHome extends StatefulWidget {
  const ManagerHome({super.key});
  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().fetchCustomers();
      context.read<TargetProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final tabs = [
      const DashboardScreen(),
      const CustomersScreen(),
      const AnalyticsScreen(),
      const ReportsScreen(),
      const UploadScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Management', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await auth.logout();
            if (mounted) Navigator.pushReplacementNamed(context, '/');
          }),
        ],
      ),
      body: tabs[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.upload_file_outlined), activeIcon: Icon(Icons.upload_file), label: 'Upload'),
        ],
      ),
    );
  }
}
