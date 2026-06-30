import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'booking_requests_screen.dart';
import 'confirmed_orders_screen.dart';
import 'order_history_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const BookingRequestsScreen(),
    const ConfirmedOrdersScreen(),
    const OrderHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF171717),
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
