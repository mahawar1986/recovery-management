import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../manager/manager_home.dart';
import '../agent/agent_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email    = TextEditingController();
  final _password = TextEditingController();
  bool _obscure   = true;
  final _form     = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    final auth   = context.read<AuthProvider>();
    final ok     = await auth.login(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => auth.isManager ? const ManagerHome() : const AgentHome()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Login failed'), backgroundColor: AppColors.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.center, colors: [AppColors.primaryDark, AppColors.bg])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 48),
              Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.account_balance, color: Colors.white, size: 38)),
              const SizedBox(height: 16),
              const Text('Recovery Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
              const Text('Sign in to continue', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 40),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _form,
                    child: Column(children: [
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email / User ID', prefixIcon: Icon(Icons.person_outline)),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _password, obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure)),
                        ),
                        validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.loading ? null : _login,
                          child: auth.loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('LOGIN', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1)),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
