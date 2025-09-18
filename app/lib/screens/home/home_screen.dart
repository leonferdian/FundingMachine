import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/app_theme.dart';
import '../../widgets/primary_button.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'profile_screen.dart';
import 'funding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const FundingScreen(),
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _pageController.jumpToPage(index);
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: const Color(0xFFA0AEC0),
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined, size: 24),
              activeIcon: Icon(Icons.dashboard_rounded, size: 24),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined, size: 24),
              activeIcon: Icon(Icons.receipt_long_rounded, size: 24),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: 24),
              activeIcon: Icon(Icons.add_circle_rounded, size: 24),
              label: 'Fund',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person_rounded, size: 24),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                // Handle fund action
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
              elevation: 2,
            )
          : null,
    );
  }
}

// Placeholder screens for the tabs
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dashboard Screen'));
  }
}

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Transactions Screen'));
  }
}

class FundingScreen extends StatelessWidget {
  const FundingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Funding Screen'));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Screen'));
  }
}
