import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('EDIT PROFILE', 
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: Colors.white)
        ),
      ),
      body: DynamicGradientBackground(
        child: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 80,
            left: 20,
            right: 20,
            bottom: 40,
          ),
          children: [
            _buildProfileImage(),
            const SizedBox(height: 32),
            _buildSectionHeader('PERSONAL INFORMATION', Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField('Full Name', 'Shivam Rajput'),
            const SizedBox(height: 12),
            _buildTextField('Email Address', 'shivam@example.com'),
            const SizedBox(height: 12),
            _buildTextField('Phone Number', '+91 98765 43210'),
            const SizedBox(height: 32),
            _buildSectionHeader('FINANCIAL STATUS', Icons.account_balance_wallet_outlined),
            const SizedBox(height: 16),
            _buildTextField('Annual Income', '₹24,00,000'),
            const SizedBox(height: 12),
            _buildTextField('Occupation', 'Software Architect'),
            const SizedBox(height: 48),
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFEAB308)),
        const SizedBox(width: 10),
        Text(title, 
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.4), letterSpacing: 1.5)
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEAB308).withOpacity(0.5), width: 1.5),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF1E293B),
              child: Icon(Icons.person_rounded, size: 50, color: const Color(0xFFEAB308).withOpacity(0.9)),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFEAB308), shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Color(0xFF0F172A), size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      opacity: 0.1,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: const Color(0xFFEAB308).withOpacity(0.3), blurRadius: 20, spreadRadius: -5)
        ]
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEAB308),
          foregroundColor: const Color(0xFF0F172A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0)),
      ),
    );
  }
}
