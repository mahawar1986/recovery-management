import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import 'login_screen.dart';
import '../manager/manager_home.dart';
import '../agent/agent_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.checkAuth();
    if (!mounted) return;
    if (auth.isLoggedIn) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => auth.isManager ? const ManagerHome() : const AgentHome()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary]),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppColors.teal.withOpacity(0.5), blurRadius: 30, spreadRadius: 4)]),
                child: const Icon(Icons.account_balance, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('Recovery Management', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text('Loan Recovery System', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6), letterSpacing: 2)),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2),
            ]),
          ),
        ),
      ),
    );
  }
}
