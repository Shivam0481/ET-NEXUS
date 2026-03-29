import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'subscription_screen.dart';
// For some placeholders

class SettingsScreen extends StatelessWidget {
  final VoidCallback onSignOut;
  
  const SettingsScreen({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('SETTINGS', 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 2.0,
            color: Colors.white,
          )
        ),
      ),
      body: DynamicGradientBackground(
        child: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 80,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          children: [
            _buildSection(context, 'ACCOUNT', [
              _buildSettingsTile(context, 'Edit Profile', Icons.person_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
              _buildSettingsTile(context, 'Notifications', Icons.notifications_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
              _buildSettingsTile(context, 'ET Prime Subscription', Icons.star_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()))),
            ]),
            const SizedBox(height: 32),
            _buildSection(context, 'ET NEXUS AI', [
              _buildSettingsTile(context, 'Reset Conversation', Icons.refresh, () => _showComingSoon(context, 'Reset')),
              _buildSettingsTile(context, 'Clear Financial Profile', Icons.delete_outline, () => _showComingSoon(context, 'Clear Profile')),
              _buildSettingsTile(context, 'Privacy Settings', Icons.shield_outlined, () => _showComingSoon(context, 'Privacy')),
            ]),
            const SizedBox(height: 32),
            _buildSection(context, 'ABOUT', [
              _buildSettingsTile(context, 'Help & Support', Icons.help_outline, () => _showComingSoon(context, 'Support')),
              _buildSettingsTile(context, 'Terms & Conditions', Icons.description_outlined, () => _showComingSoon(context, 'Terms')),
              _buildSettingsTile(context, 'App Version 1.0.0', Icons.info_outline, () => _showComingSoon(context, 'Version Info')),
            ]),
            const SizedBox(height: 48),
            GlassCard(
              padding: EdgeInsets.zero,
              opacity: 0.1,
              borderRadius: BorderRadius.circular(20),
              child: ListTile(
                onTap: onSignOut,
                leading: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
                title: const Text('SIGN OUT', 
                  style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0)
                ),
                trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.white24),
              ),
            ),
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(title, 
            style: TextStyle(
              fontSize: 9, 
              fontWeight: FontWeight.w900, 
              color: Colors.white.withOpacity(0.3),
              letterSpacing: 1.5
            )
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          opacity: 0.1,
          borderRadius: BorderRadius.circular(24),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFEAB308).withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: const Color(0xFFEAB308).withOpacity(0.7)),
      ),
      title: Text(title, 
        style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700)
      ),
      trailing: Icon(Icons.chevron_right, size: 14, color: Colors.white.withOpacity(0.1)),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
