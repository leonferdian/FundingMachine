import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock user data - replace with actual user data
  final Map<String, dynamic> _user = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+1 (555) 123-4567',
    'avatarUrl': null,
    'joinedDate': 'January 2023',
  };

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.person_outline,
      'title': 'Personal Information',
      'onTap': () {
        // TODO: Navigate to personal info screen
      },
    },
    {
      'icon': Icons.credit_card,
      'title': 'Bank Accounts',
      'onTap': () {
        // TODO: Navigate to bank accounts screen
      },
    },
    {
      'icon': Icons.lock_outline,
      'title': 'Security',
      'onTap': () {
        // TODO: Navigate to security settings
      },
    },
    {
      'icon': Icons.notifications_none,
      'title': 'Notifications',
      'onTap': () {
        // TODO: Navigate to notification settings
      },
    },
    {
      'icon': Icons.help_outline,
      'title': 'Help & Support',
      'onTap': () {
        // TODO: Show help & support options
      },
    },
    {
      'icon': Icons.info_outline,
      'title': 'About',
      'onTap': () {
        // TODO: Show about dialog
      },
    },
  ];

  Future<void> _signOut() async {
    // TODO: Implement sign out logic
    await Future.delayed(const Duration(seconds: 1));
    
    // Navigate to login screen and remove all previous routes
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with user info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // User avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: _user['avatarUrl'] != null
                          ? ClipOval(
                              child: Image.network(
                                _user['avatarUrl'],
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white.withOpacity(0.8),
                            ),
                    ),
                    const SizedBox(height: 12),
                    // User name
                    Text(
                      _user['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // User email
                    Text(
                      _user['email'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Member since
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Member since ${_user['joinedDate']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Profile menu items
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              ..._menuItems.map((item) => _buildMenuItem(
                    icon: item['icon'],
                    title: item['title'],
                    onTap: item['onTap'],
                  )),
              const SizedBox(height: 24),
              // Sign out button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: PrimaryButton(
                  onPressed: () {
                    _showSignOutDialog();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red[100]!),
                ),
              ),
              const SizedBox(height: 24),
              // App version
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: AppTheme.lightTextColor,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.lightTextColor,
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showSignOutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
