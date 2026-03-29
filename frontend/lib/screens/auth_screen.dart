import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';
import '../services/api_service.dart';

class AuthScreen extends StatefulWidget {
  final Function(String name, String email, String investorType) onAuthComplete;
  
  const AuthScreen({super.key, required this.onAuthComplete});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _investorType = 'Long Term'; // Default

  bool _isLoading = false;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call for now since we're in "proceed" mode and want to show the UI
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
    
    // Pass user info back to main.dart to update auth state
    widget.onAuthComplete(
      _isLogin ? 'Sophisticated Investor' : _nameController.text, 
      _emailController.text,
      _investorType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: DynamicGradientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAB308).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFEAB308).withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFFEAB308), size: 40),
                ),
                const SizedBox(height: 24),
                const Text('ET NEXUS', 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 3.0, color: Colors.white)
                ),
                const SizedBox(height: 8),
                Text(_isLogin ? 'WELCOME BACK' : 'CREATE YOUR STRATEGIC PROFILE', 
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.4), letterSpacing: 2.0)
                ),
                const SizedBox(height: 48),

                GlassCard(
                  padding: const EdgeInsets.all(32),
                  opacity: 0.1,
                  borderRadius: BorderRadius.circular(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_isLogin) ...[
                          _buildTextField('FULL NAME', _nameController, Icons.person_outline),
                          const SizedBox(height: 20),
                        ],
                        _buildTextField('EMAIL ADDRESS', _emailController, Icons.email_outlined),
                        const SizedBox(height: 20),
                        _buildTextField('PASSWORD', _passwordController, Icons.lock_outline, isPassword: true),
                        
                        if (!_isLogin) ...[
                          const SizedBox(height: 32),
                          const Text('INVESTOR TYPE', 
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1.5)
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTypeOption('Long Term', Icons.trending_up)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildTypeOption('Short Term', Icons.timer_outlined)),
                            ],
                          ),
                        ],

                        const SizedBox(height: 40),
                        
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEAB308),
                            foregroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)))
                            : Text(_isLogin ? 'SIGN IN' : 'GET STARTED', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                TextButton(
                  onPressed: _toggleAuthMode,
                  child: Text(_isLogin ? "DON'T HAVE AN ACCOUNT? SIGN UP" : "ALREADY HAVE AN ACCOUNT? SIGN IN", 
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFFEAB308).withOpacity(0.7), letterSpacing: 1.0)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFFEAB308).withOpacity(0.5), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (val) => val!.isEmpty ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption(String label, IconData icon) {
    bool isSelected = _investorType == label;
    return GestureDetector(
      onTap: () => setState(() => _investorType = label),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAB308).withOpacity(0.1) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFFEAB308).withOpacity(0.5) : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFEAB308) : Colors.white24, size: 20),
            const SizedBox(height: 8),
            Text(label.toUpperCase(), 
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : Colors.white24, letterSpacing: 1.0)
            ),
          ],
        ),
      ),
    );
  }
}
