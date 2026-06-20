import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../utils/app_theme.dart';
import 'agent_dashboard.dart';
import 'agent_customers.dart';
import 'visit_log_screen.dart';

class AgentHome extends StatefulWidget {
  const AgentHome({super.key});
  @override
  State<AgentHome> createState() => _AgentHomeState();
}

class _AgentHomeState extends State<AgentHome> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      context.read<CustomerProvider>().fetchCustomers(agentId: uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${auth.user?.name.split(' ')[0] ?? 'Agent'}', style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.teal,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await auth.logout();
          }),
        ],
      ),
      body: [const AgentDashboard(), const AgentCustomers()][_tab],
      floatingActionButton: _tab == 1 ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisitLogScreen())),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Log Visit'),
        backgroundColor: AppColors.teal,
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab, onTap: (i) => setState(() => _tab = i),
        selectedItemColor: AppColors.teal, unselectedItemColor: AppColors.textMuted,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'My Accounts'),
        ],
      ),
    );
  }
}
